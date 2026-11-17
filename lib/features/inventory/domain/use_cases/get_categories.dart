import '../entities/category_entity.dart';
import '../repositories/inventory_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final InventoryRepository _repository;

  Stream<List<CategoryEntity>> call() => _repository.watchCategories();
}
