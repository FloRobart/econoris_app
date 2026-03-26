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
    return FormField<String>(
      initialValue: selectedCategory,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La categorie est obligatoire';
        }

        return null;
      },
      builder: (state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Categorie',
            border: const OutlineInputBorder(),
            errorText: state.errorText,
          ),
          child: SizedBox(
            height: 44,
            child: SingleChildScrollView(
              scrollDirection: direction,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (var index = 0; index < categories.length; index++) ...[
                    if (index > 0) const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(categories[index]),
                      selected: categories[index] == selectedCategory,
                      onSelected: (_) {
                        onCategorySelected(categories[index]);
                        state.didChange(categories[index]);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
