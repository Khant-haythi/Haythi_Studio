import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/core/database/app_database.dart';
import 'package:haythi_studio/features/inventory/data/data_sources/local/inventory_local_data_source_impl.dart';
import 'package:haythi_studio/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:haythi_studio/features/inventory/domain/entities/material_entity.dart';

void main() {
  late AppDatabase database;
  late InventoryRepositoryImpl repository;

  MaterialEntity material({
    required String id,
    required String name,
    required double quantity,
    double reorderLevel = 10,
  }) {
    final now = DateTime(2026, 10, 31);
    return MaterialEntity(
      id: id,
      name: name,
      categoryId: 'category-beads',
      unitId: 'unit-pcs',
      quantityOnHand: quantity,
      reorderLevel: reorderLevel,
      averageUnitCost: 100,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = InventoryRepositoryImpl(
      InventoryLocalDataSourceImpl(database),
    );
  });

  tearDown(() => database.close());

  test('adds, reads, and updates an active material', () async {
    final bead = material(
      id: 'material-aquamarine',
      name: 'Aquamarine Bead',
      quantity: 20,
    );

    await repository.addMaterial(bead);
    expect((await repository.watchMaterials().first).single.name, bead.name);

    await repository.updateMaterial(bead.copyWith(name: 'Blue Bead'));
    expect(
      (await repository.getMaterialById(bead.id))?.name,
      'Blue Bead',
    );
  });

  test('separates low-stock and out-of-stock materials', () async {
    await repository.addMaterial(
      material(id: 'material-ok', name: 'Enough', quantity: 11),
    );
    await repository.addMaterial(
      material(id: 'material-low', name: 'Low', quantity: 5),
    );
    await repository.addMaterial(
      material(id: 'material-out', name: 'Out', quantity: 0),
    );

    final lowStock = await repository.watchLowStockMaterials().first;
    final outOfStock = await repository.watchOutOfStockMaterials().first;

    expect(lowStock.map((item) => item.id), ['material-low']);
    expect(outOfStock.map((item) => item.id), ['material-out']);
  });

  test('archive hides a material without deleting its database row', () async {
    final bead = material(
      id: 'material-pearl',
      name: 'Pearl Bead',
      quantity: 8,
    );
    await repository.addMaterial(bead);

    await repository.deleteMaterial(bead.id);

    expect(await repository.watchMaterials().first, isEmpty);
    expect(await repository.getMaterialById(bead.id), isNull);
    final storedRow = await (database.select(database.materials)
          ..where((row) => row.id.equals(bead.id)))
        .getSingle();
    expect(storedRow.isActive, isFalse);
  });
}
