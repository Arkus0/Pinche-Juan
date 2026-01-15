import '../models/conversion_result.dart';
import '../models/ingredient.dart';
import '../models/measurement_unit.dart';

/// Service for performing unit conversions with density support
///
/// This service handles both simple conversions (within same measurement type)
/// and complex conversions (volume <-> weight) that require ingredient density
class UnitConversionService {
  /// Convert a value from one unit to another
  ///
  /// For conversions between volume and weight, an [ingredient] must be provided.
  /// Returns [ConversionResult] with the converted value and metadata.
  ///
  /// Algorithm:
  /// 1. Check if conversion requires density (different measurement types)
  /// 2. If same type: Convert fromUnit -> base unit -> toUnit
  /// 3. If different type:
  ///    a. Convert fromUnit to its base unit
  ///    b. Apply density conversion (volume <-> weight)
  ///    c. Convert to target base unit
  ///    d. Convert to toUnit
  ConversionResult convert({
    required double value,
    required MeasurementUnit fromUnit,
    required MeasurementUnit toUnit,
    Ingredient? ingredient,
  }) {
    // Same unit? No conversion needed
    if (fromUnit == toUnit) {
      return ConversionResult(
        value: value,
        fromUnit: fromUnit,
        toUnit: toUnit,
        originalValue: value,
      );
    }

    final requiresDensity = fromUnit.requiresDensity(toUnit);

    // Validate density requirement
    if (requiresDensity && ingredient == null) {
      throw ConversionException(
        'Density-based conversion requires an ingredient',
        fromUnit: fromUnit,
        toUnit: toUnit,
      );
    }

    // Step 1: Convert to base unit of source measurement type
    final baseValue = fromUnit.toBase(value);

    // Step 2: Apply density conversion if needed
    final convertedBaseValue = requiresDensity
        ? _convertWithDensity(
            baseValue,
            fromType: fromUnit.type,
            toType: toUnit.type,
            density: ingredient!.densityGramsPerMl,
          )
        : baseValue;

    // Step 3: Convert from target base unit to target unit
    final result = toUnit.fromBase(convertedBaseValue);

    return ConversionResult(
      value: result,
      fromUnit: fromUnit,
      toUnit: toUnit,
      originalValue: value,
      ingredientUsed: ingredient?.name,
      densityUsed: ingredient?.densityGramsPerMl,
      requiresDensity: requiresDensity,
    );
  }

  /// Apply density conversion between volume and weight
  ///
  /// Density is always expressed as g/ml (grams per milliliter)
  ///
  /// Formulas:
  /// - Volume to Weight: weight(g) = volume(ml) × density(g/ml)
  /// - Weight to Volume: volume(ml) = weight(g) ÷ density(g/ml)
  double _convertWithDensity({
    required double baseValue,
    required MeasurementType fromType,
    required MeasurementType toType,
    required double density,
  }) {
    if (fromType == MeasurementType.volume &&
        toType == MeasurementType.weight) {
      // Volume (ml) to Weight (g)
      // Example: 100ml flour × 0.59 g/ml = 59g
      return baseValue * density;
    } else if (fromType == MeasurementType.weight &&
        toType == MeasurementType.volume) {
      // Weight (g) to Volume (ml)
      // Example: 59g flour ÷ 0.59 g/ml = 100ml
      return baseValue / density;
    }

    // Should never reach here if called correctly
    throw ConversionException(
      'Invalid density conversion types',
      fromUnit: null,
      toUnit: null,
    );
  }

  /// Calculate baker's percentage
  ///
  /// Baker's math expresses ingredients as percentages of flour weight
  /// Flour is always 100%, other ingredients are relative to flour
  ///
  /// Example:
  /// - Flour: 500g (100%)
  /// - Water: 350g (70% hydration)
  /// - Salt: 10g (2%)
  double calculateBakersPercentage({
    required double ingredientWeight,
    required double flourWeight,
  }) {
    if (flourWeight == 0) {
      throw ArgumentError('Flour weight cannot be zero');
    }
    return (ingredientWeight / flourWeight) * 100;
  }

  /// Calculate ingredient weight from baker's percentage
  ///
  /// Given flour weight and a percentage, calculate ingredient amount
  ///
  /// Example: 70% hydration on 500g flour = 350g water
  double fromBakersPercentage({
    required double percentage,
    required double flourWeight,
  }) {
    return (percentage / 100) * flourWeight;
  }

  /// Batch scaling: multiply a recipe by a factor
  ///
  /// Example: Scale 1.5x for 50% more servings
  double scaleQuantity({
    required double originalAmount,
    required double scaleFactor,
  }) {
    if (scaleFactor <= 0) {
      throw ArgumentError('Scale factor must be positive');
    }
    return originalAmount * scaleFactor;
  }
}

/// Exception thrown when conversion fails
class ConversionException implements Exception {
  const ConversionException(
    this.message, {
    this.fromUnit,
    this.toUnit,
  });

  final String message;
  final MeasurementUnit? fromUnit;
  final MeasurementUnit? toUnit;

  @override
  String toString() {
    final buffer = StringBuffer('ConversionException: $message');
    if (fromUnit != null || toUnit != null) {
      buffer.write(' (');
      if (fromUnit != null) buffer.write('from: ${fromUnit!.symbol}');
      if (fromUnit != null && toUnit != null) buffer.write(', ');
      if (toUnit != null) buffer.write('to: ${toUnit!.symbol}');
      buffer.write(')');
    }
    return buffer.toString();
  }
}
