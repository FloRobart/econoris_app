import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:flutter/material.dart';

/// Section d'aperçu du profil, affichant des informations générales sur l'utilisateur.
class OverViewSection extends StatefulWidget {
  const OverViewSection({
    super.key,
    required this.pseudo,
    required this.email,
    this.onPseudoChanged,
  });

  final String pseudo;
  final String email;
  final ValueChanged<String>? onPseudoChanged;

  @override
  State<OverViewSection> createState() => _OverViewSectionState();
}

class _OverViewSectionState extends State<OverViewSection> {
  late final TextEditingController _pseudoController;
  late final FocusNode _pseudoFocusNode;
  late String _currentPseudo;
  bool _isEditingPseudo = false;

  @override
  void initState() {
    super.initState();
    _currentPseudo = widget.pseudo;
    _pseudoController = TextEditingController(text: _currentPseudo);
    _pseudoFocusNode = FocusNode()
      ..addListener(() {
        if (!_pseudoFocusNode.hasFocus && _isEditingPseudo) {
          _commitPseudo();
        }
      });
  }

  @override
  void didUpdateWidget(covariant OverViewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pseudo != oldWidget.pseudo && !_isEditingPseudo) {
      _currentPseudo = widget.pseudo;
      _pseudoController.text = _currentPseudo;
    }
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _pseudoFocusNode.dispose();
    super.dispose();
  }

  void _startPseudoEditing() {
    setState(() {
      _isEditingPseudo = true;
      _pseudoController
        ..text = _currentPseudo
        ..selection = TextSelection(
          baseOffset: _currentPseudo.length,
          extentOffset: _currentPseudo.length,
        );
    });
    _pseudoFocusNode.requestFocus();
  }

  void _commitPseudo() {
    final String nextPseudo = _pseudoController.text.trim().replaceAll("'", "");
    final String resolvedPseudo = nextPseudo.isEmpty
        ? _currentPseudo
        : nextPseudo;

    if (resolvedPseudo != _currentPseudo) {
      widget.onPseudoChanged?.call(resolvedPseudo);
    }

    setState(() {
      _currentPseudo = resolvedPseudo;
      _pseudoController.text = resolvedPseudo;
      _isEditingPseudo = false;
    });
  }

  String get getUserInitial {
    if (_currentPseudo.isEmpty) return '';
    return _currentPseudo
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .take(2)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardContainer(
      child: Row(
        children: [
          /// User avatar with initials
          CircleAvatar(
            radius: 34,
            child: Text(getUserInitial, style: const TextStyle(fontSize: 20)),
          ),

          const SizedBox(width: 12),

          /// User info (pseudo and email)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Pseudo editable au clic
                    Expanded(
                      child: _isEditingPseudo
                          ? TextField(
                              controller: _pseudoController,
                              focusNode: _pseudoFocusNode,
                              autofocus: true,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _commitPseudo(),
                              style: theme.textTheme.titleMedium,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: const UnderlineInputBorder(),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                          : GestureDetector(
                              onTap: _startPseudoEditing,
                              child: Text(
                                _currentPseudo,
                                style: theme.textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                    ),

                    const SizedBox(width: 8),

                    /// Edit profile button
                    Icon(
                      Icons.edit,
                      color: theme.iconTheme.color,
                      size: theme.textTheme.titleMedium?.fontSize ?? 16,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// Email
                Text(widget.email, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
