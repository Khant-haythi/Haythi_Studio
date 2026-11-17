import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
import '../../../inventory/presentation/widgets/material_photo.dart';
import '../../domain/entities/product_draft.dart';
import '../../domain/use_cases/calculate_product_cost.dart';
import '../providers/product_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});
  @override
  ConsumerState<AddProductScreen> createState() => _AddProductState();
}

class _AddProductState extends ConsumerState<AddProductScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _category = TextEditingController(),
      _description = TextEditingController();
  final _price = TextEditingController(text: '0'),
      _labor = TextEditingController(text: '0'),
      _extra = TextEditingController(text: '0');
  final Map<String, TextEditingController> _recipe = {};
  String? _photo;
  bool _saving = false;
  @override
  void dispose() {
    for (final controller in [
      _name,
      _category,
      _description,
      _price,
      _labor,
      _extra,
      ..._recipe.values
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (_recipe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one recipe material.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(addProductProvider)(ProductDraft(
        id: '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
        name: _name.text,
        category: _category.text,
        description: _description.text.trim(),
        imagePath: _photo,
        sellingPrice: int.parse(_price.text),
        laborCost: int.parse(_labor.text),
        additionalCost: int.parse(_extra.text),
        recipe: {
          for (final entry in _recipe.entries)
            entry.key: double.parse(entry.value.text)
        },
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Product and recipe saved. Ready stock starts at 0.')));
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save product: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _money(TextEditingController controller, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
            controller: controller,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label, suffixText: 'MMK'),
            onChanged: (_) => setState(() {}),
            validator: (value) => (int.tryParse(value ?? '') ?? -1) < 0
                ? 'Enter a whole amount of zero or more'
                : null),
      );
  @override
  Widget build(BuildContext context) {
    final materials = ref.watch(materialsProvider);
    final units = ref.watch(unitsProvider);
    return PopScope(
        canPop: !_saving,
        child: Scaffold(
          appBar: AppBar(title: const Text('Add Product')),
          body: materials.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Could not load materials.')),
              data: (items) => units.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      const Center(child: Text('Could not load units.')),
                  data: (unitItems) {
                    final byId = {for (final item in items) item.id: item};
                    final unitMap = {
                      for (final item in unitItems) item.id: item
                    };
                    ProductCostEstimate? estimate;
                    try {
                      estimate = const CalculateProductCost()(
                          materials: _recipe.entries
                              .map((entry) => RecipeCostItem(
                                  quantity: double.parse(entry.value.text),
                                  averageUnitCost:
                                      byId[entry.key]!.averageUnitCost))
                              .toList(),
                          sellingPrice: int.parse(_price.text),
                          laborCost: int.parse(_labor.text),
                          additionalCost: int.parse(_extra.text));
                    } catch (_) {/* Show the preview once inputs are valid. */}
                    return Form(
                        key: _form,
                        child: ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              MaterialPhotoPicker(
                                  path: _photo,
                                  enabled: !_saving,
                                  onChanged: (path) =>
                                      setState(() => _photo = path)),
                              const SizedBox(height: 20),
                              Text('Your creation',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: _name,
                                  enabled: !_saving,
                                  maxLength: 150,
                                  decoration: const InputDecoration(
                                      labelText: 'Product name'),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Enter a name'
                                          : null),
                              TextFormField(
                                  controller: _category,
                                  enabled: !_saving,
                                  maxLength: 100,
                                  decoration: const InputDecoration(
                                      labelText: 'Product category',
                                      hintText: 'Earrings, bracelets...'),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Enter a category'
                                          : null),
                              TextFormField(
                                  controller: _description,
                                  enabled: !_saving,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                      labelText: 'Description (optional)')),
                              const SizedBox(height: 24),
                              Text('Recipe for one product',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const Text(
                                  'For earrings sold as a pair, enter materials for one pair.'),
                              const SizedBox(height: 12),
                              if (items.isEmpty)
                                const Text(
                                    'Add materials in Inventory before creating a recipe.'),
                              for (final entry in _recipe.entries)
                                Card(
                                    child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(children: [
                                          Expanded(
                                              child: TextFormField(
                                                  controller: entry.value,
                                                  enabled: !_saving,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  decoration: InputDecoration(
                                                      labelText: byId[entry.key]
                                                              ?.name ??
                                                          'Unavailable material',
                                                      suffixText: unitMap[
                                                              byId[entry.key]
                                                                  ?.unitId]
                                                          ?.symbol),
                                                  onChanged: (_) =>
                                                      setState(() {}),
                                                  validator: (text) {
                                                    final quantity =
                                                        double.tryParse(
                                                            text ?? '');
                                                    if (!byId
                                                        .containsKey(entry.key))
                                                      return 'Remove unavailable material';
                                                    if (quantity == null ||
                                                        !quantity.isFinite ||
                                                        quantity <= 0)
                                                      return 'Enter a positive quantity';
                                                    if (unitMap[byId[entry.key]
                                                                    ?.unitId]
                                                                ?.allowsDecimal ==
                                                            false &&
                                                        quantity !=
                                                            quantity
                                                                .roundToDouble())
                                                      return 'Enter a whole quantity';
                                                    return null;
                                                  })),
                                          IconButton(
                                              tooltip: 'Remove material',
                                              onPressed: _saving
                                                  ? null
                                                  : () => setState(() {
                                                        _recipe
                                                            .remove(entry.key)
                                                            ?.dispose();
                                                      }),
                                              icon: const Icon(Icons.close)),
                                        ]))),
                              OutlinedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Recipe Material'),
                                  onPressed: _saving
                                      ? null
                                      : () async {
                                          final id = await showModalBottomSheet<
                                                  String>(
                                              context: context,
                                              showDragHandle: true,
                                              builder: (sheetContext) =>
                                                  SafeArea(
                                                      child: ListView(
                                                          shrinkWrap: true,
                                                          children: [
                                                        for (final item in items
                                                            .where((item) =>
                                                                !_recipe
                                                                    .containsKey(
                                                                        item
                                                                            .id)))
                                                          ListTile(
                                                              title: Text(
                                                                  item.name),
                                                              subtitle: Text(
                                                                  '${item.averageUnitCost} MMK / ${unitMap[item.unitId]?.symbol ?? 'unit'}'),
                                                              onTap: () =>
                                                                  Navigator.pop(
                                                                      sheetContext,
                                                                      item.id)),
                                                        if (items.every(
                                                            (item) => _recipe
                                                                .containsKey(
                                                                    item.id)))
                                                          const ListTile(
                                                              title: Text(
                                                                  'No more materials available')),
                                                      ])));
                                          if (id != null && mounted)
                                            setState(() => _recipe[id] =
                                                TextEditingController(
                                                    text: '1'));
                                        }),
                              const SizedBox(height: 24),
                              Text('Pricing',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              _money(_price, 'Selling price'),
                              _money(_labor, 'Labor cost'),
                              _money(_extra, 'Additional cost'),
                              AnimatedSize(
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                          ? Duration.zero
                                          : const Duration(milliseconds: 200),
                                  child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: estimate == null
                                              ? const Text(
                                                  'Complete the recipe and prices to preview cost.')
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                      Text(
                                                          'Estimated cost: ${estimate.totalCost} MMK'),
                                                      Text(
                                                          'Estimated profit: ${estimate.profit} MMK'),
                                                      Text(
                                                          'Margin: ${estimate.marginPercent?.toStringAsFixed(1) ?? '—'}%'),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                          'Based on current average material costs. Saving does not consume stock.'),
                                                    ])))),
                              const SizedBox(height: 20),
                              FilledButton(
                                  onPressed: _saving ? null : _save,
                                  style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF8F4B5C),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(50)),
                                  child: Text(
                                      _saving ? 'Saving...' : 'Save Product')),
                              const SizedBox(height: 24),
                            ]));
                  })),
        ));
  }
}
