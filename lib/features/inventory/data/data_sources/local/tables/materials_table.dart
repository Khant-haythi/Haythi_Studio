import 'package:drift/drift.dart';

import 'categories_table.dart';
import 'units_table.dart';

@DataClassName('MaterialRow')
class Materials extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 150)();

  TextColumn get categoryId => text().references(
        Categories,
        #id,
        onDelete: KeyAction.restrict,
      )();

  TextColumn get unitId => text().references(
        Units,
        #id,
        onDelete: KeyAction.restrict,
      )();

  RealColumn get quantityOnHand => real().withDefault(const Constant(0))();

  RealColumn get reorderLevel => real().withDefault(const Constant(0))();

  IntColumn get averageUnitCost => integer().withDefault(const Constant(0))();

  TextColumn get imagePath => text().nullable()();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
