import '../entities/material_purchase_entity.dart';

class CalculateMaterialPurchase {
  const CalculateMaterialPurchase();

  MaterialPurchaseEntity call({
    required String id,
    required String materialId,
    required String supplierId,
    required double packageQuantity,
    required String packageUnitName,
    required double unitsPerPackage,
    required int totalCost,
    required DateTime purchaseDate,
    required DateTime createdAt,
    String? notes,
  }) {
    final trimmedId = id.trim();
    final trimmedMaterialId = materialId.trim();
    final trimmedSupplierId = supplierId.trim();
    final trimmedPackageUnitName = packageUnitName.trim();

    if (trimmedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty');
    }
    if (trimmedMaterialId.isEmpty) {
      throw ArgumentError.value(
        materialId,
        'materialId',
        'Cannot be empty',
      );
    }
    if (trimmedSupplierId.isEmpty) {
      throw ArgumentError.value(
        supplierId,
        'supplierId',
        'Cannot be empty',
      );
    }
    if (trimmedPackageUnitName.isEmpty) {
      throw ArgumentError.value(
        packageUnitName,
        'packageUnitName',
        'Cannot be empty',
      );
    }
    if (packageQuantity <= 0) {
      throw ArgumentError.value(
        packageQuantity,
        'packageQuantity',
        'Must be greater than zero',
      );
    }
    if (unitsPerPackage <= 0) {
      throw ArgumentError.value(
        unitsPerPackage,
        'unitsPerPackage',
        'Must be greater than zero',
      );
    }
    if (totalCost <= 0) {
      throw ArgumentError.value(
        totalCost,
        'totalCost',
        'Must be greater than zero',
      );
    }

    final stockQuantityAdded = packageQuantity * unitsPerPackage;
    final baseUnitCost = (totalCost / stockQuantityAdded).round();
    final trimmedNotes = notes?.trim();

    return MaterialPurchaseEntity(
      id: trimmedId,
      materialId: trimmedMaterialId,
      supplierId: trimmedSupplierId,
      packageQuantity: packageQuantity,
      packageUnitName: trimmedPackageUnitName,
      unitsPerPackage: unitsPerPackage,
      stockQuantityAdded: stockQuantityAdded,
      totalCost: totalCost,
      baseUnitCost: baseUnitCost,
      purchaseDate: purchaseDate,
      notes: trimmedNotes == null || trimmedNotes.isEmpty ? null : trimmedNotes,
      createdAt: createdAt,
    );
  }
}
