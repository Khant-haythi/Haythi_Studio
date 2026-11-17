import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_providers.dart';
import '../widgets/material_photo.dart';

class MaterialDetailsScreen extends ConsumerStatefulWidget {
  const MaterialDetailsScreen({required this.materialId, super.key});
  final String materialId;
  @override
  ConsumerState<MaterialDetailsScreen> createState() => _MaterialDetailsState();
}

class _MaterialDetailsState extends ConsumerState<MaterialDetailsScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _reorder = TextEditingController();
  String? _category;
  String? _imagePath;
  bool _editing = false;
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    _reorder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final latest = await ref
          .read(inventoryRepositoryProvider)
          .getMaterialById(widget.materialId);
      if (latest == null) throw StateError('Material unavailable');
      await ref.read(updateMaterialProvider)(latest.copyWith(
          name: _name.text.trim(),
          imagePath: _imagePath,
          clearImagePath: _imagePath == null,
          categoryId: _category,
          reorderLevel: double.parse(_reorder.text.trim())));
      if (mounted) setState(() => _editing = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not save changes. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final units = ref.watch(unitsProvider).asData?.value ?? [];
    return PopScope(
        canPop: !_saving,
        child: Scaffold(
          appBar: AppBar(
              title: Text(_editing ? 'Edit Material' : 'Material Details')),
          body: ref.watch(materialsProvider).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) =>
                    const Center(child: Text('Could not load material.')),
                data: (items) {
                  final matches =
                      items.where((item) => item.id == widget.materialId);
                  if (matches.isEmpty) {
                    return const Center(
                        child: Text('Material is no longer available.'));
                  }
                  final material = matches.first;
                  final unit =
                      units.where((item) => item.id == material.unitId);
                  final category = (categories.asData?.value ?? [])
                      .where((item) => item.id == material.categoryId);
                  return Form(
                      key: _form,
                      child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Center(
                                child: _editing
                                    ? MaterialPhotoPicker(
                                        path: _imagePath,
                                        enabled: !_saving,
                                        onChanged: (path) =>
                                            setState(() => _imagePath = path))
                                    : MaterialPhoto(
                                        path: material.imagePath, size: 180)),
                            const SizedBox(height: 24),
                            if (!_editing) ...[
                              Text(material.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 16),
                              Card(
                                  child: Column(children: [
                                ListTile(
                                    title: const Text('Category'),
                                    trailing: Text(category.isEmpty
                                        ? '—'
                                        : category.first.name)),
                                ListTile(
                                    title: const Text('Quantity'),
                                    trailing: Text(
                                        '${material.quantityOnHand} ${unit.isEmpty ? '' : unit.first.symbol}')),
                                ListTile(
                                    title: const Text('Reorder level'),
                                    trailing: Text('${material.reorderLevel}')),
                                ListTile(
                                    title: const Text('Average unit cost'),
                                    trailing: Text(
                                        '${material.averageUnitCost} MMK')),
                              ])),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit Material'),
                                  onPressed: () => setState(() {
                                        _name.text = material.name;
                                        _reorder.text =
                                            material.reorderLevel.toString();
                                        _category = material.categoryId;
                                        _imagePath = material.imagePath;
                                        _editing = true;
                                      })),
                            ] else ...[
                              TextFormField(
                                  controller: _name,
                                  enabled: !_saving,
                                  maxLength: 150,
                                  decoration: const InputDecoration(
                                      labelText: 'Material name'),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Enter a name'
                                          : null),
                              const SizedBox(height: 16),
                              categories.when(
                                  loading: () =>
                                      const LinearProgressIndicator(),
                                  error: (_, _) => const Text(
                                      'Categories unavailable. Please try again later.'),
                                  data: (values) =>
                                      DropdownButtonFormField<String>(
                                        initialValue: values.any(
                                                (item) => item.id == _category)
                                            ? _category
                                            : null,
                                        decoration: const InputDecoration(
                                            labelText: 'Category'),
                                        items: values
                                            .map((item) => DropdownMenuItem(
                                                value: item.id,
                                                child: Text(item.name)))
                                            .toList(),
                                        onChanged: _saving
                                            ? null
                                            : (value) => _category = value,
                                        validator: (value) => value == null
                                            ? 'Choose a category'
                                            : null,
                                      )),
                              const SizedBox(height: 20),
                              TextFormField(
                                  controller: _reorder,
                                  enabled: !_saving,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: 'Reorder level'),
                                  validator: (text) {
                                    final value =
                                        double.tryParse(text?.trim() ?? '');
                                    return value == null ||
                                            !value.isFinite ||
                                            value < 0
                                        ? 'Enter a valid number of zero or more'
                                        : null;
                                  }),
                              const SizedBox(height: 24),
                              FilledButton(
                                  onPressed: _saving || !categories.hasValue
                                      ? null
                                      : _save,
                                  child: Text(
                                      _saving ? 'Saving...' : 'Save Changes')),
                              TextButton(
                                  onPressed: _saving
                                      ? null
                                      : () => setState(() => _editing = false),
                                  child: const Text('Cancel')),
                            ],
                          ]));
                },
              ),
        ));
  }
}
