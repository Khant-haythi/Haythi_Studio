import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/unit_entity.dart';
import '../providers/inventory_providers.dart';
import '../widgets/inventory_material_card.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final materials = ref.watch(materialsProvider);
    final categories = ref.watch(categoriesProvider);
    final units = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
                cursorColor: const Color(0xFF8F4B5C),
                decoration: InputDecoration(
                  hintText: 'Search materials...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFE3A9B6)
                        : const Color(0xFF8F4B5C),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF30252F)
                      : const Color(0xFFFFF0F4),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF59404F)
                          : const Color(0xFFF0D9E0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFE3A9B6)
                          : const Color(0xFF8F4B5C),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: categories.when(
                  data: _buildCategoryFilters,
                  loading: () => const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, _) => const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Categories unavailable'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: materials.when(
                  data: (items) => units.when(
                    data: (unitItems) => _buildMaterialList(items, unitItems),
                    loading: _buildLoading,
                    error: _buildError,
                  ),
                  loading: _buildLoading,
                  error: _buildError,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('add-material-button'),
                onPressed: () {
                  context.push('/materials/new');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Material'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(List<CategoryEntity> categories) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _CategoryChip(
          label: 'All',
          selected: _selectedCategoryId == null,
          onSelected: () => setState(() => _selectedCategoryId = null),
        ),
        for (final category in categories) ...[
          const SizedBox(width: 8),
          _CategoryChip(
            label: category.name,
            selected: _selectedCategoryId == category.id,
            onSelected: () {
              setState(() => _selectedCategoryId = category.id);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMaterialList(
    List<MaterialEntity> materials,
    List<UnitEntity> units,
  ) {
    final filtered = materials.where((material) {
      final matchesSearch = material.name.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategoryId == null ||
          material.categoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList(growable: false);

    if (filtered.isEmpty) {
      final hasFilter = _searchQuery.isNotEmpty || _selectedCategoryId != null;
      return _InventoryEmptyState(hasFilter: hasFilter);
    }

    final unitsById = {for (final unit in units) unit.id: unit};
    return ListView.separated(
      key: const Key('materials-list'),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final material = filtered[index];
        return InventoryMaterialCard(
          onTap: () =>
              context.push('/materials/${Uri.encodeComponent(material.id)}'),
          material: material,
          unit: unitsById[material.unitId],
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(Object error, StackTrace stackTrace) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 36),
          const SizedBox(height: 8),
          const Text('Could not load inventory'),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}

class _InventoryEmptyState extends StatelessWidget {
  const _InventoryEmptyState({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilter ? 'No matching materials' : 'No materials yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            hasFilter
                ? 'Try another search or category.'
                : 'Add your first material to start tracking stock.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
