import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/features/inventory/domain/use_cases/calculate_material_purchase.dart';

void main() {
  const calculatePurchase = CalculateMaterialPurchase();
  final purchaseDate = DateTime(2026, 10, 28);

  test('calculates stock and cost for one string of stones', () {
    final purchase = calculatePurchase(
      id: 'purchase-1',
      materialId: 'material-pearl',
      supplierId: 'supplier-a',
      packageQuantity: 1,
      packageUnitName: 'string',
      unitsPerPackage: 20,
      totalCost: 20000,
      purchaseDate: purchaseDate,
      createdAt: purchaseDate,
    );

    expect(purchase.stockQuantityAdded, 20);
    expect(purchase.baseUnitCost, 1000);
  });

  test('calculates stock for multiple packages', () {
    final purchase = calculatePurchase(
      id: 'purchase-2',
      materialId: 'material-pearl',
      supplierId: 'supplier-a',
      packageQuantity: 2,
      packageUnitName: 'string',
      unitsPerPackage: 20,
      totalCost: 20000,
      purchaseDate: purchaseDate,
      createdAt: purchaseDate,
    );

    expect(purchase.stockQuantityAdded, 40);
    expect(purchase.baseUnitCost, 500);
  });

  test('rounds cost per base unit to the nearest MMK', () {
    final purchase = calculatePurchase(
      id: 'purchase-3',
      materialId: 'material-pearl',
      supplierId: 'supplier-a',
      packageQuantity: 1,
      packageUnitName: 'string',
      unitsPerPackage: 30,
      totalCost: 10000,
      purchaseDate: purchaseDate,
      createdAt: purchaseDate,
    );

    expect(purchase.baseUnitCost, 333);
  });

  test('rejects zero package quantity', () {
    expect(
      () => calculatePurchase(
        id: 'purchase-4',
        materialId: 'material-pearl',
        supplierId: 'supplier-a',
        packageQuantity: 0,
        packageUnitName: 'string',
        unitsPerPackage: 20,
        totalCost: 20000,
        purchaseDate: purchaseDate,
        createdAt: purchaseDate,
      ),
      throwsArgumentError,
    );
  });

  test('rejects zero units per package', () {
    expect(
      () => calculatePurchase(
        id: 'purchase-5',
        materialId: 'material-pearl',
        supplierId: 'supplier-a',
        packageQuantity: 1,
        packageUnitName: 'string',
        unitsPerPackage: 0,
        totalCost: 20000,
        purchaseDate: purchaseDate,
        createdAt: purchaseDate,
      ),
      throwsArgumentError,
    );
  });

  test('rejects zero total cost', () {
    expect(
      () => calculatePurchase(
        id: 'purchase-6',
        materialId: 'material-pearl',
        supplierId: 'supplier-a',
        packageQuantity: 1,
        packageUnitName: 'string',
        unitsPerPackage: 20,
        totalCost: 0,
        purchaseDate: purchaseDate,
        createdAt: purchaseDate,
      ),
      throwsArgumentError,
    );
  });
}
