import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/material_entity.dart';
import '../../../domain/entities/unit_entity.dart';
import '../../mappers/inventory_reference_mapper.dart';
import '../../mappers/material_mapper.dart';
import 'inventory_local_data_source.dart';

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  const InventoryLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _database.watchActiveCategories().map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Stream<List<UnitEntity>> watchUnits() {
    return _database.watchActiveUnits().map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Stream<List<MaterialEntity>> watchMaterials() {
    final query = _database.select(_database.materials)
      ..where((row) => row.isActive.equals(true))
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);

    return query.watch().map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Stream<List<MaterialEntity>> watchLowStockMaterials() {
    final query = _database.select(_database.materials)
      ..where(
        (row) =>
            row.isActive.equals(true) &
            row.quantityOnHand.isBiggerThanValue(0) &
            row.quantityOnHand.isSmallerOrEqual(row.reorderLevel),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.quantityOnHand)]);

    return query.watch().map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Stream<List<MaterialEntity>> watchOutOfStockMaterials() {
    final query = _database.select(_database.materials)
      ..where(
        (row) =>
            row.isActive.equals(true) &
            row.quantityOnHand.isSmallerOrEqualValue(0),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);

    return query.watch().map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Future<MaterialEntity?> getMaterialById(String id) async {
    final row = await (_database.select(_database.materials)
          ..where(
            (row) => row.id.equals(id) & row.isActive.equals(true),
          ))
        .getSingleOrNull();

    return row?.toEntity();
  }

  @override
  Future<void> addMaterial(MaterialEntity material) async {
    await _database.into(_database.materials).insert(material.toCompanion());
  }

  @override
  Future<void> updateMaterial(MaterialEntity material) async {
    final changedRows = await (_database.update(_database.materials)
          ..where(
            (row) => row.id.equals(material.id) & row.isActive.equals(true),
          ))
        .write(
      material.copyWith(updatedAt: DateTime.now()).toCompanion(),
    );

    if (changedRows != 1) {
      throw StateError('Active material ${material.id} does not exist.');
    }
  }

  @override
  Future<void> archiveMaterial(String id) async {
    final changedRows = await (_database.update(_database.materials)
          ..where((row) => row.id.equals(id) & row.isActive.equals(true)))
        .write(
      MaterialsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (changedRows != 1) {
      throw StateError('Active material $id does not exist.');
    }
  }
}
