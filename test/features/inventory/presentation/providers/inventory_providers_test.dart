import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haythi_studio/core/database/app_database.dart';
import 'package:haythi_studio/core/providers/database_provider.dart';
import 'package:haythi_studio/features/inventory/domain/entities/material_entity.dart';
import 'package:haythi_studio/features/inventory/presentation/providers/inventory_providers.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('providers connect use cases and repository to the Drift database',
      () async {
    final now = DateTime(2026, 10, 31);
    final material = MaterialEntity(
      id: 'material-provider-test',
      name: 'Aquamarine Bead',
      categoryId: 'category-beads',
      unitId: 'unit-pcs',
      quantityOnHand: 5,
      reorderLevel: 10,
      averageUnitCost: 120,
      createdAt: now,
      updatedAt: now,
    );

    await container.read(addMaterialProvider)(material);

    final repository = container.read(inventoryRepositoryProvider);
    final materials = await repository.watchMaterials().first;
    final lowStock = await repository.watchLowStockMaterials().first;
    final outOfStock = await repository.watchOutOfStockMaterials().first;

    expect(materials, [material]);
    expect(lowStock, [material]);
    expect(outOfStock, isEmpty);
  });

  test('repository and use cases are shared inside one container', () {
    expect(
      identical(
        container.read(inventoryRepositoryProvider),
        container.read(inventoryRepositoryProvider),
      ),
      isTrue,
    );
    expect(
      identical(
        container.read(addMaterialProvider),
        container.read(addMaterialProvider),
      ),
      isTrue,
    );
  });
}
