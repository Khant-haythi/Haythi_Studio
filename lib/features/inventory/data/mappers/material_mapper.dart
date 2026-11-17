import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/material_entity.dart';

extension MaterialRowMapper on MaterialRow {
  MaterialEntity toEntity() {
    return MaterialEntity(
      id: id,
      name: name,
      categoryId: categoryId,
      unitId: unitId,
      quantityOnHand: quantityOnHand,
      reorderLevel: reorderLevel,
      averageUnitCost: averageUnitCost,
      imagePath: imagePath,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension MaterialEntityMapper on MaterialEntity {
  MaterialsCompanion toCompanion() {
    return MaterialsCompanion(
      id: Value(id),
      name: Value(name.trim()),
      categoryId: Value(categoryId),
      unitId: Value(unitId),
      quantityOnHand: Value(quantityOnHand),
      reorderLevel: Value(reorderLevel),
      averageUnitCost: Value(averageUnitCost),
      imagePath: Value(imagePath),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
