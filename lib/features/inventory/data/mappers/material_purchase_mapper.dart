import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/material_purchase_entity.dart';

extension MaterialPurchaseRowMapper on MaterialPurchaseRow {
  MaterialPurchaseEntity toEntity() {
    return MaterialPurchaseEntity(
      id: id,
      materialId: materialId,
      supplierId: supplierId,
      packageQuantity: packageQuantity,
      packageUnitName: packageUnitName,
      unitsPerPackage: unitsPerPackage,
      stockQuantityAdded: stockQuantityAdded,
      totalCost: totalCost,
      baseUnitCost: baseUnitCost,
      purchaseDate: purchaseDate,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

extension MaterialPurchaseEntityMapper on MaterialPurchaseEntity {
  MaterialPurchasesCompanion toCompanion() {
    return MaterialPurchasesCompanion.insert(
      id: id,
      materialId: materialId,
      supplierId: supplierId,
      packageQuantity: packageQuantity,
      packageUnitName: packageUnitName,
      unitsPerPackage: unitsPerPackage,
      stockQuantityAdded: stockQuantityAdded,
      totalCost: totalCost,
      baseUnitCost: baseUnitCost,
      purchaseDate: purchaseDate,
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }
}
