import 'package:drift/drift.dart';
import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/product_draft.dart';

class ProductLocalDataSource {
  const ProductLocalDataSource(this.database);
  final AppDatabase database;
  Future<void> addProduct(ProductDraft product) =>
      database.transaction(() async {
        for (final entry in product.recipe.entries) {
          final material = await (database.select(database.materials)
                ..where((row) =>
                    row.id.equals(entry.key) & row.isActive.equals(true)))
              .getSingleOrNull();
          if (material == null)
            throw StateError('A recipe material is no longer available.');
          final unit = await (database.select(database.units)
                ..where((row) => row.id.equals(material.unitId)))
              .getSingle();
          if (!unit.allowsDecimal &&
              entry.value != entry.value.roundToDouble()) {
            throw ArgumentError('${material.name} requires a whole quantity.');
          }
        }
        await database.into(database.products).insert(ProductsCompanion.insert(
            id: product.id,
            name: product.name.trim(),
            category: product.category.trim(),
            sellingPrice: product.sellingPrice,
            laborCost: Value(product.laborCost),
            additionalCost: Value(product.additionalCost),
            description: Value(product.description),
            imagePath: Value(product.imagePath)));
        for (final entry in product.recipe.entries) {
          await database.into(database.productMaterials).insert(
              ProductMaterialsCompanion.insert(
                  productId: product.id,
                  materialId: entry.key,
                  quantity: entry.value));
        }
      });
}
