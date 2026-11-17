import '../entities/product_draft.dart';
import '../repositories/product_repository.dart';

class AddProduct {
  const AddProduct(this.repository);
  final ProductRepository repository;
  Future<void> call(ProductDraft product) {
    if (product.id.isEmpty ||
        product.name.trim().isEmpty ||
        product.name.trim().length > 150 ||
        product.category.trim().isEmpty ||
        product.category.trim().length > 100 ||
        product.sellingPrice < 0 ||
        product.laborCost < 0 ||
        product.additionalCost < 0 ||
        product.recipe.isEmpty ||
        product.recipe.entries.any((item) =>
            item.key.isEmpty || !item.value.isFinite || item.value <= 0)) {
      throw ArgumentError(
          'Complete the product details and enter positive recipe quantities.');
    }
    return repository.addProduct(product);
  }
}
