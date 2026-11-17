import '../entities/material_entity.dart';
import '../repositories/inventory_repository.dart';

class GetOutOfStockMaterials {
  const GetOutOfStockMaterials(this._repository);

  final InventoryRepository _repository;

  Stream<List<MaterialEntity>> call() {
    return _repository.watchOutOfStockMaterials();
  }
}
