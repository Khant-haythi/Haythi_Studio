import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/app/app.dart';

void main() {
  testWidgets('shows the HayThi Studio dashboard', (tester) async {
    await tester.pumpWidget(const HayThiStudioApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Welcome to HayThi Studio'), findsOneWidget);
  });

  testWidgets('switches tabs and opens the add menu', (tester) async {
    await tester.pumpWidget(const HayThiStudioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Inventory will be added here.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('What would you like to add?'), findsOneWidget);
    expect(find.text('Add Material'), findsOneWidget);
  });
}
