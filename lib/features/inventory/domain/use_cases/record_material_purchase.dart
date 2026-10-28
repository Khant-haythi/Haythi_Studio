import '../entities/material_purchase_entity.dart';
import '../repositories/material_purchase_repository.dart';

class RecordMaterialPurchase {
  const RecordMaterialPurchase(this._repository);

  final MaterialPurchaseRepository _repository;

  Future<void> call(MaterialPurchaseEntity purchase) {
    return _repository.recordPurchase(purchase);
  }
}
