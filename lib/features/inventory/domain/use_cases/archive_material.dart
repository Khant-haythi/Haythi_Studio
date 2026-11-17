import '../repositories/inventory_repository.dart';

class ArchiveMaterial {
  const ArchiveMaterial(this._repository);

  final InventoryRepository _repository;

  Future<void> call(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Cannot be empty');
    }
    return _repository.deleteMaterial(id);
  }
}
