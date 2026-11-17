import '../entities/product_draft.dart';

abstract interface class ProductRepository {
  Future<void> addProduct(ProductDraft product);
}
