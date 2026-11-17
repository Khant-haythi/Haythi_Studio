import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  // Product categories (e.g. Earrings) are distinct from material categories.
  TextColumn get category => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get sellingPrice =>
      integer().check(sellingPrice.isBiggerOrEqualValue(0))();
  IntColumn get laborCost => integer()
      .withDefault(const Constant(0))
      .check(laborCost.isBiggerOrEqualValue(0))();
  IntColumn get additionalCost => integer()
      .withDefault(const Constant(0))
      .check(additionalCost.isBiggerOrEqualValue(0))();
  IntColumn get readyStock => integer()
      .withDefault(const Constant(0))
      .check(readyStock.isBiggerOrEqualValue(0))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  @override
  Set<Column<Object>> get primaryKey => {id};
}
