import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/features/products/domain/use_cases/calculate_product_cost.dart';

void main() {
  const calculate = CalculateProductCost();
  test('includes recipe, labor, and additional cost in estimated profit', () {
    final result = calculate(materials: const [
      RecipeCostItem(quantity: 2, averageUnitCost: 500),
      RecipeCostItem(quantity: 2, averageUnitCost: 100)
    ], sellingPrice: 3000, laborCost: 500, additionalCost: 100);
    expect(result.materialCost, 1200);
    expect(result.totalCost, 1800);
    expect(result.profit, 1200);
    expect(result.marginPercent, 40);
  });
  test('rounds fractional material costs once and handles zero selling price',
      () {
    final result = calculate(materials: const [
      RecipeCostItem(quantity: 0.5, averageUnitCost: 101),
      RecipeCostItem(quantity: 0.5, averageUnitCost: 101)
    ], sellingPrice: 0);
    expect(result.totalCost, 101);
    expect(result.profit, -101);
    expect(result.marginPercent, isNull);
  });
  test('rejects invalid quantities', () {
    expect(
        () => calculate(materials: const [
              RecipeCostItem(quantity: double.nan, averageUnitCost: 100)
            ], sellingPrice: 1000),
        throwsArgumentError);
  });
}
