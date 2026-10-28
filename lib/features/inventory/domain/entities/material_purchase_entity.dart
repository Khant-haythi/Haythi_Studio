class MaterialPurchaseEntity {
  const MaterialPurchaseEntity({
    required this.id,
    required this.materialId,
    required this.supplierId,
    required this.packageQuantity,
    required this.packageUnitName,
    required this.unitsPerPackage,
    required this.stockQuantityAdded,
    required this.totalCost,
    required this.baseUnitCost,
    required this.purchaseDate,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String materialId;
  final String supplierId;
  final double packageQuantity;
  final String packageUnitName;
  final double unitsPerPackage;
  final double stockQuantityAdded;
  final int totalCost;
  final int baseUnitCost;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;

  MaterialPurchaseEntity copyWith({
    String? id,
    String? materialId,
    String? supplierId,
    double? packageQuantity,
    String? packageUnitName,
    double? unitsPerPackage,
    double? stockQuantityAdded,
    int? totalCost,
    int? baseUnitCost,
    DateTime? purchaseDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return MaterialPurchaseEntity(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      supplierId: supplierId ?? this.supplierId,
      packageQuantity: packageQuantity ?? this.packageQuantity,
      packageUnitName: packageUnitName ?? this.packageUnitName,
      unitsPerPackage: unitsPerPackage ?? this.unitsPerPackage,
      stockQuantityAdded: stockQuantityAdded ?? this.stockQuantityAdded,
      totalCost: totalCost ?? this.totalCost,
      baseUnitCost: baseUnitCost ?? this.baseUnitCost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MaterialPurchaseEntity &&
            other.id == id &&
            other.materialId == materialId &&
            other.supplierId == supplierId &&
            other.packageQuantity == packageQuantity &&
            other.packageUnitName == packageUnitName &&
            other.unitsPerPackage == unitsPerPackage &&
            other.stockQuantityAdded == stockQuantityAdded &&
            other.totalCost == totalCost &&
            other.baseUnitCost == baseUnitCost &&
            other.purchaseDate == purchaseDate &&
            other.notes == notes &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        materialId,
        supplierId,
        packageQuantity,
        packageUnitName,
        unitsPerPackage,
        stockQuantityAdded,
        totalCost,
        baseUnitCost,
        purchaseDate,
        notes,
        createdAt,
      );
}
