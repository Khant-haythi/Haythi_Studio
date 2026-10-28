import '../../domain/entities/material_purchase_entity.dart';
import '../../domain/repositories/material_purchase_repository.dart';
import '../data_sources/local/material_purchase_local_data_source.dart';
import '../mappers/material_purchase_mapper.dart';

class MaterialPurchaseRepositoryImpl implements MaterialPurchaseRepository {
  const MaterialPurchaseRepositoryImpl(this._localDataSource);

  final MaterialPurchaseLocalDataSource _localDataSource;

  @override
  Future<void> recordPurchase(MaterialPurchaseEntity purchase) {
    return _localDataSource.recordPurchase(purchase);
  }

  @override
  Stream<List<MaterialPurchaseEntity>> watchPurchasesForMaterial(
    String materialId,
  ) {
    return _localDataSource.watchPurchasesForMaterial(materialId).map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }

  @override
  Stream<List<MaterialPurchaseEntity>> watchPurchasesForSupplier(
    String supplierId,
  ) {
    return _localDataSource.watchPurchasesForSupplier(supplierId).map(
          (rows) => rows.map((row) => row.toEntity()).toList(growable: false),
        );
  }
}
