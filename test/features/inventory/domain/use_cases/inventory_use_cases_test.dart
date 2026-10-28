import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/features/inventory/domain/entities/material_entity.dart';
import 'package:haythi_studio/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:haythi_studio/features/inventory/domain/use_cases/add_material.dart';
import 'package:haythi_studio/features/inventory/domain/use_cases/get_materials.dart';

void main() {
  late _FakeInventoryRepository repository;
  late MaterialEntity material;

  setUp(() {
    repository = _FakeInventoryRepository();
    material = MaterialEntity(
      id: 'material-1',
      name: 'Aquamarine Bead',
      categoryId: 'category-beads',
      unitId: 'unit-pcs',
      quantityOnHand: 120,
      reorderLevel: 20,
      averageUnitCost: 120,
      createdAt: DateTime(2026, 10, 27),
      updatedAt: DateTime(2026, 10, 27),
    );
  });

  test('GetMaterials emits materials from the repository', () async {
    repository.materials.add(material);

    final result = GetMaterials(repository)();

    await expectLater(result, emits([material]));
  });

  test('AddMaterial stores a valid material', () async {
    await AddMaterial(repository)(material);

    expect(repository.materials, [material]);
  });

  test('AddMaterial rejects an empty name', () async {
    final invalidMaterial = material.copyWith(name: '  ');

    expect(
      () => AddMaterial(repository)(invalidMaterial),
      throwsArgumentError,
    );
    expect(repository.materials, isEmpty);
  });

  test('material exposes its stock status', () {
    expect(material.isLowStock, isFalse);
    expect(material.isOutOfStock, isFalse);
    expect(material.copyWith(quantityOnHand: 10).isLowStock, isTrue);
    expect(material.copyWith(quantityOnHand: 0).isOutOfStock, isTrue);
  });
}

class _FakeInventoryRepository implements InventoryRepository {
  final List<MaterialEntity> materials = [];

  @override
  Future<void> addMaterial(MaterialEntity material) async {
    materials.add(material);
  }

  @override
  Future<void> deleteMaterial(String id) async {
    materials.removeWhere((material) => material.id == id);
  }

  @override
  Future<MaterialEntity?> getMaterialById(String id) async {
    for (final material in materials) {
      if (material.id == id) return material;
    }
    return null;
  }

  @override
  Future<void> updateMaterial(MaterialEntity material) async {
    final index = materials.indexWhere((item) => item.id == material.id);
    if (index != -1) materials[index] = material;
  }

  @override
  Stream<List<MaterialEntity>> watchMaterials() {
    return Stream.value(List.unmodifiable(materials));
  }
}
