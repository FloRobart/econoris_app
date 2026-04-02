import 'package:flutter/material.dart';

/// Champ de formulaire pour sélectionner une catégorie parmi une liste horizontale de choix.
class CategoriesField extends StatelessWidget {
  const CategoriesField({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.direction = Axis.horizontal,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final sortedCategories = [...categories]..sort((a, b) => a.compareTo(b));
    final dropdownValue = sortedCategories.contains(selectedCategory)
        ? selectedCategory
        : null;

    return DropdownButtonFormField<String>(
      initialValue: dropdownValue,
      isExpanded: true,
      menuMaxHeight: kMinInteractiveDimension * 5,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La categorie est obligatoire';
        }

        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Categorie',
        border: OutlineInputBorder(),
      ),
      hint: const Text('Selectionner une categorie'),
      items: sortedCategories
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onCategorySelected(value);
        }
      },
    );
  }
}
