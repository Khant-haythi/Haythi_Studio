import '../../domain/entities/product_draft.dart';
import '../../domain/repositories/product_repository.dart';
import '../data_sources/local/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this.source);
  final ProductLocalDataSource source;
  @override
  Future<void> addProduct(ProductDraft product) => source.addProduct(product);
}
