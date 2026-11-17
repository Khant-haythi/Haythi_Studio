class ProductDraft {
  const ProductDraft(
      {required this.id,
      required this.name,
      required this.category,
      required this.sellingPrice,
      required this.laborCost,
      required this.additionalCost,
      required this.recipe,
      this.description,
      this.imagePath});
  final String id, name, category;
  final int sellingPrice, laborCost, additionalCost;
  final String? description, imagePath;
  final Map<String, double> recipe;
}
