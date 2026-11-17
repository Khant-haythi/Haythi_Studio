import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/data_sources/local/inventory_local_data_source.dart';
import '../../data/data_sources/local/inventory_local_data_source_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/unit_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/use_cases/add_material.dart';
import '../../domain/use_cases/archive_material.dart';
import '../../domain/use_cases/get_low_stock_materials.dart';
import '../../domain/use_cases/get_categories.dart';
import '../../domain/use_cases/get_materials.dart';
import '../../domain/use_cases/get_out_of_stock_materials.dart';
import '../../domain/use_cases/get_units.dart';
import '../../domain/use_cases/update_material.dart';

final inventoryLocalDataSourceProvider = Provider<InventoryLocalDataSource>(
  (ref) => InventoryLocalDataSourceImpl(ref.watch(appDatabaseProvider)),
);

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => InventoryRepositoryImpl(
    ref.watch(inventoryLocalDataSourceProvider),
  ),
);

final addMaterialProvider = Provider<AddMaterial>(
  (ref) => AddMaterial(ref.watch(inventoryRepositoryProvider)),
);

final updateMaterialProvider = Provider<UpdateMaterial>(
  (ref) => UpdateMaterial(ref.watch(inventoryRepositoryProvider)),
);

final archiveMaterialProvider = Provider<ArchiveMaterial>(
  (ref) => ArchiveMaterial(ref.watch(inventoryRepositoryProvider)),
);

final getMaterialsProvider = Provider<GetMaterials>(
  (ref) => GetMaterials(ref.watch(inventoryRepositoryProvider)),
);

final getLowStockMaterialsProvider = Provider<GetLowStockMaterials>(
  (ref) => GetLowStockMaterials(ref.watch(inventoryRepositoryProvider)),
);

final getOutOfStockMaterialsProvider = Provider<GetOutOfStockMaterials>(
  (ref) => GetOutOfStockMaterials(ref.watch(inventoryRepositoryProvider)),
);

final getCategoriesProvider = Provider<GetCategories>(
  (ref) => GetCategories(ref.watch(inventoryRepositoryProvider)),
);

final getUnitsProvider = Provider<GetUnits>(
  (ref) => GetUnits(ref.watch(inventoryRepositoryProvider)),
);

final materialsProvider = StreamProvider<List<MaterialEntity>>(
  (ref) => ref.watch(getMaterialsProvider)(),
);

final lowStockMaterialsProvider = StreamProvider<List<MaterialEntity>>(
  (ref) => ref.watch(getLowStockMaterialsProvider)(),
);

final outOfStockMaterialsProvider = StreamProvider<List<MaterialEntity>>(
  (ref) => ref.watch(getOutOfStockMaterialsProvider)(),
);

final categoriesProvider = StreamProvider<List<CategoryEntity>>(
  (ref) => ref.watch(getCategoriesProvider)(),
);

final unitsProvider = StreamProvider<List<UnitEntity>>(
  (ref) => ref.watch(getUnitsProvider)(),
);
