import 'package:drift/drift.dart';

import '../../../../../suppliers/data/data_sources/local/tables/suppliers_table.dart';
import 'materials_table.dart';

@DataClassName('MaterialPurchaseRow')
class MaterialPurchases extends Table {
  TextColumn get id => text()();

  TextColumn get materialId => text().references(
        Materials,
        #id,
        onDelete: KeyAction.restrict,
      )();

  TextColumn get supplierId => text().references(
        Suppliers,
        #id,
        onDelete: KeyAction.restrict,
      )();

  RealColumn get packageQuantity => real()();

  TextColumn get packageUnitName => text().withLength(min: 1, max: 50)();

  RealColumn get unitsPerPackage => real()();

  RealColumn get stockQuantityAdded => real()();

  IntColumn get totalCost => integer()();

  IntColumn get baseUnitCost => integer()();

  DateTimeColumn get purchaseDate => dateTime()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
