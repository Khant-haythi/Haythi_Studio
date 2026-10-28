import '../entities/material_entity.dart';
import '../repositories/inventory_repository.dart';

class AddMaterial {
  const AddMaterial(this._repository);

  final InventoryRepository _repository;

  Future<void> call(MaterialEntity material) async {
    if (material.name.trim().isEmpty) {
      throw ArgumentError.value(material.name, 'name', 'Cannot be empty');
    }
    if (material.categoryId.trim().isEmpty) {
      throw ArgumentError.value(
        material.categoryId,
        'categoryId',
        'Cannot be empty',
      );
    }
    if (material.unitId.trim().isEmpty) {
      throw ArgumentError.value(material.unitId, 'unitId', 'Cannot be empty');
    }
    if (material.quantityOnHand < 0) {
      throw ArgumentError.value(
        material.quantityOnHand,
        'quantityOnHand',
        'Cannot be negative',
      );
    }
    if (material.reorderLevel < 0) {
      throw ArgumentError.value(
        material.reorderLevel,
        'reorderLevel',
        'Cannot be negative',
      );
    }
    if (material.averageUnitCost < 0) {
      throw ArgumentError.value(
        material.averageUnitCost,
        'averageUnitCost',
        'Cannot be negative',
      );
    }

    await _repository.addMaterial(material);
  }
}
