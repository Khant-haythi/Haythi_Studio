import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/core/database/app_database.dart';

void main() {
  late AppDatabase database;
  final purchaseDate = DateTime(2026, 10, 28);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());

    await database.into(database.suppliers).insert(
          SuppliersCompanion.insert(
            id: 'supplier-a',
            name: 'Shwe Pearl Shop',
          ),
        );

    await database.into(database.materials).insert(
          MaterialsCompanion.insert(
            id: 'material-pearl',
            name: 'Pearl Stone',
            categoryId: 'category-beads',
            unitId: 'unit-pcs',
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and reads a supplier', () async {
    final suppliers = await database.watchActiveSuppliers().first;

    expect(suppliers, hasLength(1));
    expect(suppliers.single.name, 'Shwe Pearl Shop');
  });

  test('does not return an inactive supplier as active', () async {
    await (database.update(database.suppliers)
          ..where((supplier) => supplier.id.equals('supplier-a')))
        .write(
      SuppliersCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final suppliers = await database.watchActiveSuppliers().first;
    expect(suppliers, isEmpty);
  });

  test('stores purchase history for a material and supplier', () async {
    await _insertPurchase(database, purchaseDate);

    final byMaterial =
        await database.watchPurchasesForMaterial('material-pearl').first;
    final bySupplier =
        await database.watchPurchasesForSupplier('supplier-a').first;

    expect(byMaterial, hasLength(1));
    expect(bySupplier, hasLength(1));
    expect(byMaterial.single.stockQuantityAdded, 20);
    expect(byMaterial.single.baseUnitCost, 1000);
  });

  test('rejects a purchase with an unknown material', () async {
    final insert = database.into(database.materialPurchases).insert(
          MaterialPurchasesCompanion.insert(
            id: 'purchase-invalid-material',
            materialId: 'missing-material',
            supplierId: 'supplier-a',
            packageQuantity: 1,
            packageUnitName: 'string',
            unitsPerPackage: 20,
            stockQuantityAdded: 20,
            totalCost: 20000,
            baseUnitCost: 1000,
            purchaseDate: purchaseDate,
          ),
        );

    await expectLater(insert, throwsA(anything));
  });

  test('rejects a purchase with an unknown supplier', () async {
    final insert = database.into(database.materialPurchases).insert(
          MaterialPurchasesCompanion.insert(
            id: 'purchase-invalid-supplier',
            materialId: 'material-pearl',
            supplierId: 'missing-supplier',
            packageQuantity: 1,
            packageUnitName: 'string',
            unitsPerPackage: 20,
            stockQuantityAdded: 20,
            totalCost: 20000,
            baseUnitCost: 1000,
            purchaseDate: purchaseDate,
          ),
        );

    await expectLater(insert, throwsA(anything));
  });
}

Future<void> _insertPurchase(
  AppDatabase database,
  DateTime purchaseDate,
) async {
  await database.into(database.materialPurchases).insert(
        MaterialPurchasesCompanion.insert(
          id: 'purchase-1',
          materialId: 'material-pearl',
          supplierId: 'supplier-a',
          packageQuantity: 1,
          packageUnitName: 'string',
          unitsPerPackage: 20,
          stockQuantityAdded: 20,
          totalCost: 20000,
          baseUnitCost: 1000,
          purchaseDate: purchaseDate,
        ),
      );
}
