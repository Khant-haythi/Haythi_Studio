import '../../../../core/database/app_database.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/unit_entity.dart';

extension CategoryRowMapper on Category {
  CategoryEntity toEntity() => CategoryEntity(id: id, name: name);
}

extension UnitRowMapper on Unit {
  UnitEntity toEntity() {
    return UnitEntity(
      id: id,
      name: name,
      symbol: symbol,
      allowsDecimal: allowsDecimal,
    );
  }
}
