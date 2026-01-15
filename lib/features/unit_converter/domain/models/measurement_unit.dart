/// Measurement units supported by the KitchenOS converter
///
/// All conversions are calculated relative to base units:
/// - Volume: milliliters (ml)
/// - Weight: grams (g)
enum MeasurementUnit {
  // Volume Units
  milliliter(
    name: 'Milliliter',
    symbol: 'ml',
    type: MeasurementType.volume,
    toBaseUnit: 1.0,
  ),
  liter(
    name: 'Liter',
    symbol: 'L',
    type: MeasurementType.volume,
    toBaseUnit: 1000.0,
  ),
  teaspoon(
    name: 'Teaspoon',
    symbol: 'tsp',
    type: MeasurementType.volume,
    toBaseUnit: 4.92892,
  ),
  tablespoon(
    name: 'Tablespoon',
    symbol: 'tbsp',
    type: MeasurementType.volume,
    toBaseUnit: 14.7868,
  ),
  cup(
    name: 'Cup',
    symbol: 'cup',
    type: MeasurementType.volume,
    toBaseUnit: 236.588,
  ),
  fluidOunce(
    name: 'Fluid Ounce',
    symbol: 'fl oz',
    type: MeasurementType.volume,
    toBaseUnit: 29.5735,
  ),

  // Weight Units
  gram(
    name: 'Gram',
    symbol: 'g',
    type: MeasurementType.weight,
    toBaseUnit: 1.0,
  ),
  kilogram(
    name: 'Kilogram',
    symbol: 'kg',
    type: MeasurementType.weight,
    toBaseUnit: 1000.0,
  ),
  ounce(
    name: 'Ounce',
    symbol: 'oz',
    type: MeasurementType.weight,
    toBaseUnit: 28.3495,
  ),
  pound(
    name: 'Pound',
    symbol: 'lb',
    type: MeasurementType.weight,
    toBaseUnit: 453.592,
  );

  const MeasurementUnit({
    required this.name,
    required this.symbol,
    required this.type,
    required this.toBaseUnit,
  });

  final String name;
  final String symbol;
  final MeasurementType type;
  final double toBaseUnit;

  /// Convert a value from this unit to its base unit
  double toBase(double value) => value * toBaseUnit;

  /// Convert a value from base unit to this unit
  double fromBase(double baseValue) => baseValue / toBaseUnit;

  /// Check if conversion requires density (volume <-> weight)
  bool requiresDensity(MeasurementUnit target) => type != target.type;
}

enum MeasurementType {
  volume,
  weight;

  bool get isVolume => this == MeasurementType.volume;
  bool get isWeight => this == MeasurementType.weight;
}
