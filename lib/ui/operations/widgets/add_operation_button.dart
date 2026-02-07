import 'package:flutter/material.dart';

/// Widget réutilisable pour le bouton '+' (Add) des opérations.
///
/// Requis :
/// - [categories] : liste de catégories disponibles (au minimum)
/// - [onModeSelected] : callback appelé avec la "mode" sélectionnée (ex: 'revenue' | 'depense')
///
/// Comportement : affiche le FAB et, lorsqu'il est ouvert, deux boutons d'action
/// (Revenu / Dépense). Gère son propre état d'ouverture pour rester découplé.
class AddOperationButton extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<String> onModeSelected;
  final bool initiallyOpen;

  const AddOperationButton({
    super.key,
    required this.categories,
    required this.onModeSelected,
    this.initiallyOpen = false,
  });

  @override
  State<AddOperationButton> createState() => _AddOperationButtonState();
}

class _AddOperationButtonState extends State<AddOperationButton> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyOpen;
  }

  void _selectMode(String mode) {
    setState(() => _open = false);
    widget.onModeSelected(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSlide(
          offset: _open ? const Offset(0, 0) : const Offset(0, 0.2),
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () => _selectMode('revenue'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _selectMode('revenue'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 18,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Revenu',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        AnimatedSlide(
          offset: _open ? const Offset(0, 0) : const Offset(0, 0.2),
          duration: const Duration(milliseconds: 220),
          child: AnimatedOpacity(
            opacity: _open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () => _selectMode('depense'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _selectMode('depense'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 18,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Dépense',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        FloatingActionButton(
          onPressed: () => setState(() => _open = !_open),
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
