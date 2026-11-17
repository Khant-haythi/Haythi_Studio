class UnitEntity {
  const UnitEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.allowsDecimal,
  });

  final String id;
  final String name;
  final String symbol;
  final bool allowsDecimal;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UnitEntity &&
            other.id == id &&
            other.name == name &&
            other.symbol == symbol &&
            other.allowsDecimal == allowsDecimal;
  }

  @override
  int get hashCode => Object.hash(id, name, symbol, allowsDecimal);
}
