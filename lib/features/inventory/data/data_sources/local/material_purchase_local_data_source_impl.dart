import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/material_purchase_entity.dart';
import '../../mappers/material_purchase_mapper.dart';
import 'material_purchase_local_data_source.dart';

class MaterialPurchaseLocalDataSourceImpl
    implements MaterialPurchaseLocalDataSource {
  const MaterialPurchaseLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> recordPurchase(MaterialPurchaseEntity purchase) {
    return _database.transaction(() async {
      final material = await (_database.select(_database.materials)
            ..where((row) => row.id.equals(purchase.materialId)))
          .getSingleOrNull();

      if (material == null) {
        throw StateError('Material ${purchase.materialId} does not exist.');
      }

      final supplier = await (_database.select(_database.suppliers)
            ..where((row) => row.id.equals(purchase.supplierId)))
          .getSingleOrNull();

      if (supplier == null) {
        throw StateError('Supplier ${purchase.supplierId} does not exist.');
      }
      if (!supplier.isActive) {
        throw StateError('Supplier ${purchase.supplierId} is inactive.');
      }

      final newQuantity = material.quantityOnHand + purchase.stockQuantityAdded;
      final existingStockValue =
          material.quantityOnHand * material.averageUnitCost;
      final newAverageUnitCost =
          ((existingStockValue + purchase.totalCost) / newQuantity).round();

      await _database
          .into(_database.materialPurchases)
          .insert(purchase.toCompanion());

      final changedRows = await (_database.update(_database.materials)
            ..where((row) => row.id.equals(purchase.materialId)))
          .write(
        MaterialsCompanion(
          quantityOnHand: Value(newQuantity),
          averageUnitCost: Value(newAverageUnitCost),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (changedRows != 1) {
        throw StateError('Material stock could not be updated.');
      }
    });
  }

  @override
  Stream<List<MaterialPurchaseRow>> watchPurchasesForMaterial(
    String materialId,
  ) {
    return _database.watchPurchasesForMaterial(materialId);
  }

  @override
  Stream<List<MaterialPurchaseRow>> watchPurchasesForSupplier(
    String supplierId,
  ) {
    return _database.watchPurchasesForSupplier(supplierId);
  }
}
