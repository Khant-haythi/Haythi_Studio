import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/features/inventory/domain/entities/category_entity.dart';
import 'package:haythi_studio/features/inventory/domain/entities/material_entity.dart';
import 'package:haythi_studio/features/inventory/domain/entities/unit_entity.dart';
import 'package:haythi_studio/features/inventory/presentation/pages/inventory_screen.dart';
import 'package:haythi_studio/features/inventory/presentation/providers/inventory_providers.dart';

void main() {
  final now = DateTime(2026, 10, 31);
  final materials = [
    MaterialEntity(
      id: 'aquamarine',
      name: 'Aquamarine Bead',
      categoryId: 'beads',
      unitId: 'pcs',
      quantityOnHand: 5,
      reorderLevel: 10,
      averageUnitCost: 120,
      createdAt: now,
      updatedAt: now,
    ),
    MaterialEntity(
      id: 'eye-pin',
      name: 'Eye Pin',
      categoryId: 'findings',
      unitId: 'pcs',
      quantityOnHand: 0,
      reorderLevel: 10,
      averageUnitCost: 50,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        materialsProvider.overrideWith((ref) => Stream.value(materials)),
        categoriesProvider.overrideWith(
          (ref) => Stream.value(const [
            CategoryEntity(id: 'beads', name: 'Beads'),
            CategoryEntity(id: 'findings', name: 'Findings'),
          ]),
        ),
        unitsProvider.overrideWith(
          (ref) => Stream.value(const [
            UnitEntity(
              id: 'pcs',
              name: 'Piece',
              symbol: 'pcs',
              allowsDecimal: false,
            ),
          ]),
        ),
      ],
      child: const MaterialApp(home: InventoryScreen()),
    );
  }

  testWidgets('shows materials, quantities, and stock statuses',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Aquamarine Bead'), findsOneWidget);
    expect(find.text('5 pcs'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.text('Eye Pin'), findsOneWidget);
    expect(find.text('Out of Stock'), findsOneWidget);
  });

  testWidgets('searches and filters materials', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'eye');
    await tester.pump();
    expect(find.text('Eye Pin'), findsOneWidget);
    expect(find.text('Aquamarine Bead'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Beads'));
    await tester.pump();
    expect(find.text('Aquamarine Bead'), findsOneWidget);
    expect(find.text('Eye Pin'), findsNothing);
  });
}
