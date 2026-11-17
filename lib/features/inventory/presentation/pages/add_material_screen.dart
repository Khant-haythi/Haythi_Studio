import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/inventory_providers.dart';
import '../widgets/material_photo.dart';
import '../../../../core/providers/database_provider.dart';

class AddMaterialScreen extends ConsumerStatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  ConsumerState<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends ConsumerState<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '0');
  final _reorder = TextEditingController(text: '0');
  final _cost = TextEditingController(text: '0');
  String? _categoryId;
  String? _unitId;
  String? _imagePath;
  bool _saving = false;
  bool _allowsDecimal = true;

  Future<void> _createCategory() async {
    String enteredName = '';
    final key = GlobalKey<FormState>();
    final name = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('New Category'),
              content: Form(
                  key: key,
                  child: TextFormField(
                      autofocus: true,
                      maxLength: 100,
                      onChanged: (value) => enteredName = value.trim(),
                      decoration:
                          const InputDecoration(labelText: 'Category name'),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return 'Enter a category name';
                        if ((ref.read(categoriesProvider).asData?.value ?? [])
                            .any((item) =>
                                item.name.toLowerCase() ==
                                name.toLowerCase())) {
                          return 'This category already exists';
                        }
                        return null;
                      })),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        Navigator.pop(dialogContext, enteredName);
                      }
                    },
                    child: const Text('Save'))
              ],
            ));
    if (name == null || !mounted) return;
    final id = 'category-${DateTime.now().microsecondsSinceEpoch}';
    try {
      await ref.read(appDatabaseProvider).addCategory(id: id, name: name);
      if (mounted) setState(() => _categoryId = id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Could not add category. The name may already exist.')));
      }
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _quantity, _reorder, _cost]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateNumber(String? text, {bool money = false}) {
    final value = double.tryParse(text?.trim() ?? '');
    if (value == null || !value.isFinite || value < 0) {
      return 'Enter a valid number of zero or more';
    }
    if ((money || !_allowsDecimal) && value != value.roundToDouble()) {
      return 'Enter a whole number';
    }
    if (money && int.tryParse(text!.trim()) == null) {
      return 'Enter a whole MMK amount';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final random = Random.secure();
      final id = List.generate(
              16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
          .join();
      await ref.read(addMaterialProvider)(MaterialEntity(
        id: id,
        imagePath: _imagePath,
        name: _name.text.trim(),
        categoryId: _categoryId!,
        unitId: _unitId!,
        quantityOnHand: double.parse(_quantity.text.trim()),
        reorderLevel: double.parse(_reorder.text.trim()),
        averageUnitCost: int.parse(_cost.text.trim()),
        createdAt: now,
        updatedAt: now,
      ));
      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not save material. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final units = ref.watch(unitsProvider);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Material')),
        body: categories.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _referenceError(),
          data: (categoryItems) => units.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _referenceError(),
            data: (unitItems) {
              if (categoryItems.isEmpty || unitItems.isEmpty) {
                return const Center(
                    child: Text(
                        'Add a category and unit before creating materials.'));
              }
              return SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      MaterialPhotoPicker(
                          path: _imagePath,
                          enabled: !_saving,
                          onChanged: (path) =>
                              setState(() => _imagePath = path)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.softPink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(children: [
                          Icon(Icons.diamond_outlined,
                              size: 40, color: AppColors.primaryDark),
                          SizedBox(height: 8),
                          Text('A little detail, better stock tracking',
                              textAlign: TextAlign.center),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _name,
                        enabled: !_saving,
                        maxLength: 150,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            labelText: 'Material name',
                            hintText: 'Aquamarine Bead'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a material name'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                              onPressed: _saving ? null : _createCategory,
                              icon: const Icon(Icons.add),
                              label: const Text('New Category'))),
                      DropdownButtonFormField<String>(
                        key: ValueKey(_categoryId),
                        initialValue:
                            categoryItems.any((item) => item.id == _categoryId)
                                ? _categoryId
                                : null,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: categoryItems
                            .map((item) => DropdownMenuItem(
                                value: item.id, child: Text(item.name)))
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _categoryId = value),
                        validator: (_) =>
                            _categoryId == null ? 'Choose a category' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Base unit'),
                        items: unitItems
                            .map((item) => DropdownMenuItem(
                                value: item.id,
                                child: Text('${item.name} (${item.symbol})')))
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                  _unitId = value;
                                  _allowsDecimal = unitItems
                                      .firstWhere((item) => item.id == value)
                                      .allowsDecimal;
                                }),
                        validator: (_) =>
                            _unitId == null ? 'Choose a unit' : null,
                      ),
                      const SizedBox(height: 20),
                      _numberField(_reorder, 'Reorder level'),
                      const SizedBox(height: 24),
                      Text('Stock you already own',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      const Text(
                          'For materials you already own. Record future purchases separately to keep purchase history.',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      _numberField(_quantity, 'Quantity you already have'),
                      const SizedBox(height: 20),
                      _numberField(_cost, 'Cost per unit of existing stock',
                          money: true),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size.fromHeight(50)),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check),
                        label: Text(_saving ? 'Saving...' : 'Save Material'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label,
      {bool money = false}) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      keyboardType: TextInputType.numberWithOptions(decimal: !money),
      decoration:
          InputDecoration(labelText: label, suffixText: money ? 'MMK' : null),
      validator: (value) => _validateNumber(value, money: money),
    );
  }

  Widget _referenceError() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Could not load categories and units.'),
          TextButton(
              onPressed: () {
                ref.invalidate(categoriesProvider);
                ref.invalidate(unitsProvider);
              },
              child: const Text('Retry')),
        ]),
      );
}
