import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/core/database/app_database.dart';
import 'package:haythi_studio/features/inventory/data/data_sources/local/material_purchase_local_data_source_impl.dart';
import 'package:haythi_studio/features/inventory/data/repositories/material_purchase_repository_impl.dart';
import 'package:haythi_studio/features/inventory/domain/entities/material_purchase_entity.dart';
import 'package:haythi_studio/features/inventory/domain/use_cases/calculate_material_purchase.dart';
import 'package:haythi_studio/features/inventory/domain/use_cases/record_material_purchase.dart';

void main() {
  late AppDatabase database;
  late MaterialPurchaseRepositoryImpl repository;
  late RecordMaterialPurchase recordPurchase;
  const calculatePurchase = CalculateMaterialPurchase();
  final purchaseDate = DateTime(2026, 10, 28);

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = MaterialPurchaseRepositoryImpl(
      MaterialPurchaseLocalDataSourceImpl(database),
    );
    recordPurchase = RecordMaterialPurchase(repository);

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
            quantityOnHand: const Value(10),
            reorderLevel: const Value(5),
            averageUnitCost: const Value(400),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  test('records a purchase and updates stock and average cost', () async {
    final purchase = _purchase(
      calculatePurchase,
      id: 'purchase-1',
      packageQuantity: 1,
      unitsPerPackage: 20,
      totalCost: 20000,
      purchaseDate: purchaseDate,
    );

    await recordPurchase(purchase);

    final material = await _readMaterial(database);
    final history =
        await repository.watchPurchasesForMaterial('material-pearl').first;

    expect(material.quantityOnHand, 30);
    expect(material.averageUnitCost, 800);
    expect(history, [purchase]);
  });

  test('recalculates weighted average cost over multiple purchases', () async {
    await recordPurchase(
      _purchase(
        calculatePurchase,
        id: 'purchase-1',
        packageQuantity: 1,
        unitsPerPackage: 20,
        totalCost: 20000,
        purchaseDate: purchaseDate,
      ),
    );

    await recordPurchase(
      _purchase(
        calculatePurchase,
        id: 'purchase-2',
        packageQuantity: 1,
        unitsPerPackage: 10,
        totalCost: 5000,
        purchaseDate: purchaseDate.add(const Duration(days: 1)),
      ),
    );

    final material = await _readMaterial(database);

    expect(material.quantityOnHand, 40);
    expect(material.averageUnitCost, 725);
  });

  test('rolls back stock changes when saving the purchase fails', () async {
    final purchase = _purchase(
      calculatePurchase,
      id: 'duplicate-purchase',
      packageQuantity: 1,
      unitsPerPackage: 20,
      totalCost: 20000,
      purchaseDate: purchaseDate,
    );

    await recordPurchase(purchase);
    final materialBeforeFailure = await _readMaterial(database);

    await expectLater(recordPurchase(purchase), throwsA(anything));

    final materialAfterFailure = await _readMaterial(database);
    final history =
        await repository.watchPurchasesForMaterial('material-pearl').first;

    expect(
      materialAfterFailure.quantityOnHand,
      materialBeforeFailure.quantityOnHand,
    );
    expect(
      materialAfterFailure.averageUnitCost,
      materialBeforeFailure.averageUnitCost,
    );
    expect(history, hasLength(1));
  });
}

MaterialPurchaseEntity _purchase(
  CalculateMaterialPurchase calculatePurchase, {
  required String id,
  required double packageQuantity,
  required double unitsPerPackage,
  required int totalCost,
  required DateTime purchaseDate,
}) {
  return calculatePurchase(
    id: id,
    materialId: 'material-pearl',
    supplierId: 'supplier-a',
    packageQuantity: packageQuantity,
    packageUnitName: 'string',
    unitsPerPackage: unitsPerPackage,
    totalCost: totalCost,
    purchaseDate: purchaseDate,
    createdAt: purchaseDate,
  );
}

Future<MaterialRow> _readMaterial(AppDatabase database) {
  return (database.select(database.materials)
        ..where((row) => row.id.equals('material-pearl')))
      .getSingle();
}
