import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/inventory/data/data_sources/local/tables/categories_table.dart';
import '../../features/inventory/data/data_sources/local/tables/material_purchases_table.dart';
import '../../features/inventory/data/data_sources/local/tables/materials_table.dart';
import '../../features/inventory/data/data_sources/local/tables/units_table.dart';
import '../../features/suppliers/data/data_sources/local/tables/suppliers_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Units, Materials, Suppliers, MaterialPurchases],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'haythi_studio'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await _insertDefaultReferenceData();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(suppliers);
            await migrator.createTable(materialPurchases);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Stream<List<Category>> watchActiveCategories() {
    return (select(categories)
          ..where((category) => category.isActive.equals(true))
          ..orderBy([
            (category) => OrderingTerm.asc(category.sortOrder),
            (category) => OrderingTerm.asc(category.name),
          ]))
        .watch();
  }

  Stream<List<Unit>> watchActiveUnits() {
    return (select(units)
          ..where((unit) => unit.isActive.equals(true))
          ..orderBy([
            (unit) => OrderingTerm.asc(unit.sortOrder),
            (unit) => OrderingTerm.asc(unit.name),
          ]))
        .watch();
  }

  Stream<List<SupplierRow>> watchActiveSuppliers() {
    return (select(suppliers)
          ..where((supplier) => supplier.isActive.equals(true))
          ..orderBy([(supplier) => OrderingTerm.asc(supplier.name)]))
        .watch();
  }

  Stream<List<MaterialPurchaseRow>> watchPurchasesForMaterial(
    String materialId,
  ) {
    return (select(materialPurchases)
          ..where((purchase) => purchase.materialId.equals(materialId))
          ..orderBy([
            (purchase) => OrderingTerm.desc(purchase.purchaseDate),
          ]))
        .watch();
  }

  Stream<List<MaterialPurchaseRow>> watchPurchasesForSupplier(
    String supplierId,
  ) {
    return (select(materialPurchases)
          ..where((purchase) => purchase.supplierId.equals(supplierId))
          ..orderBy([
            (purchase) => OrderingTerm.desc(purchase.purchaseDate),
          ]))
        .watch();
  }

  Future<void> addUnit({
    required String id,
    required String name,
    required String symbol,
    required bool allowsDecimal,
  }) async {
    await into(units).insert(
      UnitsCompanion.insert(
        id: id,
        name: name.trim(),
        symbol: symbol.trim(),
        allowsDecimal: Value(allowsDecimal),
      ),
    );
  }

  Future<bool> updateUnit({
    required String id,
    required String name,
    required String symbol,
    required bool allowsDecimal,
  }) async {
    final changedRows =
        await (update(units)..where((unit) => unit.id.equals(id))).write(
      UnitsCompanion(
        name: Value(name.trim()),
        symbol: Value(symbol.trim()),
        allowsDecimal: Value(allowsDecimal),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return changedRows > 0;
  }

  Future<void> addCategory({
    required String id,
    required String name,
  }) async {
    await into(categories).insert(
      CategoriesCompanion.insert(id: id, name: name.trim()),
    );
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
  }) async {
    final changedRows = await (update(categories)
          ..where((category) => category.id.equals(id)))
        .write(
      CategoriesCompanion(
        name: Value(name.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return changedRows > 0;
  }

  Future<void> _insertDefaultReferenceData() async {
    await batch((batch) {
      batch.insertAll(categories, [
        CategoriesCompanion.insert(
          id: 'category-beads',
          name: 'Beads',
          sortOrder: const Value(0),
        ),
        CategoriesCompanion.insert(
          id: 'category-findings',
          name: 'Findings',
          sortOrder: const Value(1),
        ),
        CategoriesCompanion.insert(
          id: 'category-chains',
          name: 'Chains',
          sortOrder: const Value(2),
        ),
        CategoriesCompanion.insert(
          id: 'category-others',
          name: 'Others',
          sortOrder: const Value(3),
        ),
      ]);

      batch.insertAll(units, [
        UnitsCompanion.insert(
          id: 'unit-pcs',
          name: 'Piece',
          symbol: 'pcs',
          allowsDecimal: const Value(false),
          sortOrder: const Value(0),
        ),
        UnitsCompanion.insert(
          id: 'unit-cm',
          name: 'Centimetre',
          symbol: 'cm',
          sortOrder: const Value(1),
        ),
        UnitsCompanion.insert(
          id: 'unit-m',
          name: 'Metre',
          symbol: 'm',
          sortOrder: const Value(2),
        ),
        UnitsCompanion.insert(
          id: 'unit-g',
          name: 'Gram',
          symbol: 'g',
          sortOrder: const Value(3),
        ),
        UnitsCompanion.insert(
          id: 'unit-ml',
          name: 'Millilitre',
          symbol: 'ml',
          sortOrder: const Value(4),
        ),
      ]);
    });
  }
}
