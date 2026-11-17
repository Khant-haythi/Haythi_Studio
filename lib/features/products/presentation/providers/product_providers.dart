import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/data_sources/local/product_local_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/use_cases/add_product.dart';

final productLocalDataSourceProvider =
    Provider((ref) => ProductLocalDataSource(ref.watch(appDatabaseProvider)));
final productRepositoryProvider = Provider<ProductRepository>(
    (ref) => ProductRepositoryImpl(ref.watch(productLocalDataSourceProvider)));
final addProductProvider =
    Provider((ref) => AddProduct(ref.watch(productRepositoryProvider)));
