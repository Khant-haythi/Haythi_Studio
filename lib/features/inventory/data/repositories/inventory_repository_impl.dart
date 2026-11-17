import '../../domain/entities/category_entity.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/unit_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../data_sources/local/inventory_local_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._localDataSource);

  final InventoryLocalDataSource _localDataSource;

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _localDataSource.watchCategories();
  }

  @override
  Stream<List<UnitEntity>> watchUnits() {
    return _localDataSource.watchUnits();
  }

  @override
  Stream<List<MaterialEntity>> watchMaterials() {
    return _localDataSource.watchMaterials();
  }

  @override
  Stream<List<MaterialEntity>> watchLowStockMaterials() {
    return _localDataSource.watchLowStockMaterials();
  }

  @override
  Stream<List<MaterialEntity>> watchOutOfStockMaterials() {
    return _localDataSource.watchOutOfStockMaterials();
  }

  @override
  Future<MaterialEntity?> getMaterialById(String id) {
    return _localDataSource.getMaterialById(id);
  }

  @override
  Future<void> addMaterial(MaterialEntity material) {
    return _localDataSource.addMaterial(material);
  }

  @override
  Future<void> updateMaterial(MaterialEntity material) {
    return _localDataSource.updateMaterial(material);
  }

  @override
  Future<void> deleteMaterial(String id) {
    return _localDataSource.archiveMaterial(id);
  }
}
