import '../entities/material_entity.dart';
import '../repositories/inventory_repository.dart';
import 'add_material.dart';

class UpdateMaterial {
  const UpdateMaterial(this._repository);

  final InventoryRepository _repository;

  Future<void> call(MaterialEntity material) async {
    AddMaterial.validate(material);
    await _repository.updateMaterial(material);
  }
}
