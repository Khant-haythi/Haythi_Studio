import 'package:flutter/material.dart';
import 'material_photo.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/unit_entity.dart';

class InventoryMaterialCard extends StatelessWidget {
  const InventoryMaterialCard({
    required this.material,
    required this.unit,
    this.onTap,
    super.key,
  });

  final MaterialEntity material;
  final UnitEntity? unit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = _StockStatus.from(material);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.softPeach,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MaterialPhoto(path: material.imagePath, size: 52),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatQuantity(material.quantityOnHand)} ${unit?.symbol ?? ''}'
                          .trim(),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    if (material.averageUnitCost > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${material.averageUnitCost} MMK / ${unit?.symbol ?? 'unit'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.foregroundColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

enum _StockStatus {
  inStock('In Stock', Color(0xFFE7F4EA), AppColors.success),
  lowStock('Low Stock', Color(0xFFFFF0DA), AppColors.warning),
  outOfStock('Out of Stock', Color(0xFFFFE4E7), AppColors.error);

  const _StockStatus(
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  );

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  factory _StockStatus.from(MaterialEntity material) {
    if (material.isOutOfStock) return _StockStatus.outOfStock;
    if (material.isLowStock) return _StockStatus.lowStock;
    return _StockStatus.inStock;
  }
}
