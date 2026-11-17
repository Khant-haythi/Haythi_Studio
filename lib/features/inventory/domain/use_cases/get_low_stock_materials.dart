import '../entities/material_entity.dart';
import '../repositories/inventory_repository.dart';

class GetLowStockMaterials {
  const GetLowStockMaterials(this._repository);

  final InventoryRepository _repository;

  Stream<List<MaterialEntity>> call() {
    return _repository.watchLowStockMaterials();
  }
}
