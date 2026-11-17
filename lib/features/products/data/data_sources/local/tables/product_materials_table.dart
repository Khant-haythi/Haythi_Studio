import 'package:drift/drift.dart';
import '../../../../../inventory/data/data_sources/local/tables/materials_table.dart';
import 'products_table.dart';

@DataClassName('ProductMaterialRow')
class ProductMaterials extends Table {
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();
  TextColumn get materialId =>
      text().references(Materials, #id, onDelete: KeyAction.restrict)();
  RealColumn get quantity => real().check(quantity.isBiggerThanValue(0))();
  @override
  Set<Column<Object>> get primaryKey => {productId, materialId};
}
