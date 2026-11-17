import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/material_entity.dart';
import '../../../domain/entities/unit_entity.dart';

abstract interface class InventoryLocalDataSource {
  Stream<List<MaterialEntity>> watchMaterials();

  Stream<List<MaterialEntity>> watchLowStockMaterials();

  Stream<List<MaterialEntity>> watchOutOfStockMaterials();

  Stream<List<CategoryEntity>> watchCategories();

  Stream<List<UnitEntity>> watchUnits();

  Future<MaterialEntity?> getMaterialById(String id);

  Future<void> addMaterial(MaterialEntity material);

  Future<void> updateMaterial(MaterialEntity material);

  Future<void> archiveMaterial(String id);
}
