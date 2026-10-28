import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/material_purchase_entity.dart';

abstract interface class MaterialPurchaseLocalDataSource {
  Future<void> recordPurchase(MaterialPurchaseEntity purchase);

  Stream<List<MaterialPurchaseRow>> watchPurchasesForMaterial(
    String materialId,
  );

  Stream<List<MaterialPurchaseRow>> watchPurchasesForSupplier(
    String supplierId,
  );
}
