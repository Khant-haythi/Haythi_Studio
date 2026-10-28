import 'package:drift/drift.dart';

@DataClassName('SupplierRow')
class Suppliers extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 150)();

  TextColumn get phone => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get notes => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
