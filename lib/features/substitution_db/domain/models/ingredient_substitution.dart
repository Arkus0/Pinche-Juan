import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient_substitution.freezed.dart';
part 'ingredient_substitution.g.dart';

/// Emergency substitution data for missing ingredients
///
/// Provides alternative ingredients with ratio modifiers for quick replacements
@freezed
class IngredientSubstitution with _$IngredientSubstitution {
  const factory IngredientSubstitution({
    required String id,
    required String originalIngredient,
    required List<SubstituteOption> substitutes,
    String? category,
    String? notes,
  }) = _IngredientSubstitution;

  factory IngredientSubstitution.fromJson(Map<String, dynamic> json) =>
      _$IngredientSubstitutionFromJson(json);
}

/// A single substitute option with its conversion ratio
@freezed
class SubstituteOption with _$SubstituteOption {
  const factory SubstituteOption({
    required String ingredient,
    required double ratio,
    String? preparation,
    String? notes,
    @Default(SubstituteQuality.good) SubstituteQuality quality,
  }) = _SubstituteOption;

  factory SubstituteOption.fromJson(Map<String, dynamic> json) =>
      _$SubstituteOptionFromJson(json);

  const SubstituteOption._();

  /// Calculate the amount needed for substitution
  /// originalAmount: amount of the original ingredient
  /// Returns: amount of substitute needed
  double calculateAmount(double originalAmount) => originalAmount * ratio;

  /// Formatted ratio string for display
  String get ratioFormatted {
    if (ratio == 1.0) return '1:1';
    return '${ratio.toStringAsFixed(2)}:1';
  }

  /// Full description with preparation instructions
  String get fullDescription {
    final buffer = StringBuffer(ingredient);
    if (preparation != null) {
      buffer.write(' ($preparation)');
    }
    if (notes != null) {
      buffer.write(' - $notes');
    }
    return buffer.toString();
  }
}

/// Quality rating for a substitution
enum SubstituteQuality {
  excellent, // Nearly identical result
  good,      // Good substitute with minor differences
  fair,      // Works but noticeable difference
  emergency; // Last resort option

  String get label {
    switch (this) {
      case SubstituteQuality.excellent:
        return 'Excellent';
      case SubstituteQuality.good:
        return 'Good';
      case SubstituteQuality.fair:
        return 'Fair';
      case SubstituteQuality.emergency:
        return 'Emergency';
    }
  }

  String get emoji {
    switch (this) {
      case SubstituteQuality.excellent:
        return '⭐';
      case SubstituteQuality.good:
        return '✅';
      case SubstituteQuality.fair:
        return '⚠️';
      case SubstituteQuality.emergency:
        return '🆘';
    }
  }
}
