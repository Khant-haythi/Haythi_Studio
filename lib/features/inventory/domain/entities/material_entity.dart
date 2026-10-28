class MaterialEntity {
  const MaterialEntity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.unitId,
    required this.quantityOnHand,
    required this.reorderLevel,
    required this.averageUnitCost,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
  });

  final String id;
  final String name;
  final String categoryId;
  final String unitId;
  final double quantityOnHand;
  final double reorderLevel;
  final int averageUnitCost;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => quantityOnHand > 0 && quantityOnHand <= reorderLevel;

  bool get isOutOfStock => quantityOnHand <= 0;

  MaterialEntity copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? unitId,
    double? quantityOnHand,
    double? reorderLevel,
    int? averageUnitCost,
    String? imagePath,
    bool clearImagePath = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      unitId: unitId ?? this.unitId,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      averageUnitCost: averageUnitCost ?? this.averageUnitCost,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MaterialEntity &&
            other.id == id &&
            other.name == name &&
            other.categoryId == categoryId &&
            other.unitId == unitId &&
            other.quantityOnHand == quantityOnHand &&
            other.reorderLevel == reorderLevel &&
            other.averageUnitCost == averageUnitCost &&
            other.imagePath == imagePath &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        categoryId,
        unitId,
        quantityOnHand,
        reorderLevel,
        averageUnitCost,
        imagePath,
        createdAt,
        updatedAt,
      );
}
