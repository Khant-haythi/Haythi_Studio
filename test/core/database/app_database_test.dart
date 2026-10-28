import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haythi_studio/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('creates default material categories and units', () async {
    final categories = await database.watchActiveCategories().first;
    final units = await database.watchActiveUnits().first;

    expect(categories.map((category) => category.name), [
      'Beads',
      'Findings',
      'Chains',
      'Others',
    ]);
    expect(units.map((unit) => unit.symbol), ['pcs', 'cm', 'm', 'g', 'ml']);
  });

  test('adds and updates a custom unit without changing the schema', () async {
    await database.addUnit(
      id: 'unit-kg',
      name: 'Kilogram',
      symbol: 'kg',
      allowsDecimal: true,
    );

    var units = await database.watchActiveUnits().first;
    expect(units.any((unit) => unit.symbol == 'kg'), isTrue);

    final updated = await database.updateUnit(
      id: 'unit-kg',
      name: 'Kilogram',
      symbol: 'kgs',
      allowsDecimal: true,
    );

    units = await database.watchActiveUnits().first;
    expect(updated, isTrue);
    expect(units.any((unit) => unit.symbol == 'kgs'), isTrue);
  });

  test('adds and updates a custom category', () async {
    await database.addCategory(id: 'category-wire', name: 'Wire');

    var categories = await database.watchActiveCategories().first;
    expect(categories.any((category) => category.name == 'Wire'), isTrue);

    final updated = await database.updateCategory(
      id: 'category-wire',
      name: 'Wires',
    );

    categories = await database.watchActiveCategories().first;
    expect(updated, isTrue);
    expect(categories.any((category) => category.name == 'Wires'), isTrue);
  });
}
