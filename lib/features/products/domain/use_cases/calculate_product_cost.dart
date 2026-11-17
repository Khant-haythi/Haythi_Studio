class RecipeCostItem {
  const RecipeCostItem({required this.quantity, required this.averageUnitCost});
  final double quantity;
  final int averageUnitCost;
}

class ProductCostEstimate {
  const ProductCostEstimate(
      {required this.materialCost,
      required this.totalCost,
      required this.profit,
      required this.marginPercent});
  final int materialCost;
  final int totalCost;
  final int profit;
  // Margin is undefined when the selling price is zero.
  final double? marginPercent;
}

class CalculateProductCost {
  const CalculateProductCost();

  ProductCostEstimate call(
      {required List<RecipeCostItem> materials,
      required int sellingPrice,
      int laborCost = 0,
      int additionalCost = 0}) {
    if (sellingPrice < 0 || laborCost < 0 || additionalCost < 0) {
      throw ArgumentError('Prices and costs cannot be negative.');
    }
    if (materials.isEmpty) {
      throw ArgumentError('Add at least one recipe material.');
    }
    double sum = 0;
    for (final item in materials) {
      if (!item.quantity.isFinite ||
          item.quantity <= 0 ||
          item.averageUnitCost < 0) {
        throw ArgumentError(
            'Recipe quantities must be positive and costs non-negative.');
      }
      sum += item.quantity * item.averageUnitCost;
    }
    if (!sum.isFinite) {
      throw ArgumentError('Recipe cost is too large.');
    }
    // Round once at the end to avoid accumulating per-line rounding errors.
    final materialCost = sum.round();
    final total = materialCost + laborCost + additionalCost;
    final profit = sellingPrice - total;
    return ProductCostEstimate(
        materialCost: materialCost,
        totalCost: total,
        profit: profit,
        marginPercent: sellingPrice == 0 ? null : profit / sellingPrice * 100);
  }
}
