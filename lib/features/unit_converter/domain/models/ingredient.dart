import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

/// Represents a cooking ingredient with its physical properties
///
/// The density value is crucial for volume-to-weight conversions
/// Density is expressed in g/ml (grams per milliliter)
@freezed
class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String id,
    required String name,
    required double densityGramsPerMl,
    String? category,
    List<String>? aliases,
    @Default('') String notes,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  const Ingredient._();

  /// Common ingredients with standard densities
  static final water = Ingredient(
    id: 'water',
    name: 'Water',
    densityGramsPerMl: 1.0,
    category: 'Liquids',
  );

  static final allPurposeFlour = Ingredient(
    id: 'flour_ap',
    name: 'All-Purpose Flour',
    densityGramsPerMl: 0.59,
    category: 'Flours',
    notes: 'Sifted',
  );

  static final sugar = Ingredient(
    id: 'sugar_white',
    name: 'White Sugar',
    densityGramsPerMl: 0.85,
    category: 'Sugars',
    notes: 'Granulated',
  );
}
