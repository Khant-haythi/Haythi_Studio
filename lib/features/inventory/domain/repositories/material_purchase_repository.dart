import '../entities/material_purchase_entity.dart';

abstract interface class MaterialPurchaseRepository {
  Future<void> recordPurchase(MaterialPurchaseEntity purchase);

  Stream<List<MaterialPurchaseEntity>> watchPurchasesForMaterial(
    String materialId,
  );

  Stream<List<MaterialPurchaseEntity>> watchPurchasesForSupplier(
    String supplierId,
  );
}
