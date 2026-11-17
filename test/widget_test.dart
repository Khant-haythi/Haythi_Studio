import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/app/app.dart';
import 'package:haythi_studio/features/inventory/domain/entities/category_entity.dart';
import 'package:haythi_studio/features/inventory/domain/entities/material_entity.dart';
import 'package:haythi_studio/features/inventory/domain/entities/unit_entity.dart';
import 'package:haythi_studio/features/inventory/presentation/providers/inventory_providers.dart';

Widget buildTestApp() {
  return ProviderScope(
    overrides: [
      materialsProvider.overrideWith(
        (ref) => Stream.value(const <MaterialEntity>[]),
      ),
      categoriesProvider.overrideWith(
        (ref) => Stream.value(const <CategoryEntity>[]),
      ),
      unitsProvider.overrideWith(
        (ref) => Stream.value(const <UnitEntity>[]),
      ),
    ],
    child: const HayThiStudioApp(),
  );
}

void main() {
  testWidgets('shows the HayThi Studio dashboard', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Welcome to HayThi Studio'), findsOneWidget);
  });

  testWidgets('switches tabs and opens the add menu', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No materials yet'), findsOneWidget);
    expect(find.text('Add New Material'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('What would you like to add?'), findsOneWidget);
    expect(find.text('Add Material'), findsOneWidget);
  });
}
