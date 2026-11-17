import '../entities/unit_entity.dart';
import '../repositories/inventory_repository.dart';

class GetUnits {
  const GetUnits(this._repository);

  final InventoryRepository _repository;

  Stream<List<UnitEntity>> call() => _repository.watchUnits();
}
