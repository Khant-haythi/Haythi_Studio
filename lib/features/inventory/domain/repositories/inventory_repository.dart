import '../entities/material_entity.dart';

abstract interface class InventoryRepository {
  Stream<List<MaterialEntity>> watchMaterials();

  Future<MaterialEntity?> getMaterialById(String id);

  Future<void> addMaterial(MaterialEntity material);

  Future<void> updateMaterial(MaterialEntity material);

  Future<void> deleteMaterial(String id);
}
