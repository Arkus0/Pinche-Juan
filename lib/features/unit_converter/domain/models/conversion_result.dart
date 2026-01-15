import 'package:freezed_annotation/freezed_annotation.dart';
import 'measurement_unit.dart';

part 'conversion_result.freezed.dart';

/// Result of a unit conversion operation
///
/// Contains the converted value plus metadata about the conversion
@freezed
class ConversionResult with _$ConversionResult {
  const factory ConversionResult({
    required double value,
    required MeasurementUnit fromUnit,
    required MeasurementUnit toUnit,
    required double originalValue,
    String? ingredientUsed,
    double? densityUsed,
    @Default(false) bool requiresDensity,
  }) = _ConversionResult;

  const ConversionResult._();

  /// Formatted string representation
  String get formatted =>
      '${originalValue.toStringAsFixed(2)} ${fromUnit.symbol} = ${value.toStringAsFixed(2)} ${toUnit.symbol}';

  /// Detailed conversion info for debugging or display
  String get details {
    if (requiresDensity && densityUsed != null) {
      return 'Converted using density: ${densityUsed!.toStringAsFixed(2)} g/ml${ingredientUsed != null ? ' ($ingredientUsed)' : ''}';
    }
    return 'Direct conversion (same measurement type)';
  }
}
