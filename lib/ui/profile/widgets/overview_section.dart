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
  static const double _minPseudoWidth = 56;

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

  double _computePseudoWidth({
    required BuildContext context,
    required TextStyle? style,
    required double maxWidth,
  }) {
    final String value = _isEditingPseudo
        ? _pseudoController.text
        : _currentPseudo;
    final TextPainter painter = TextPainter(
      text: TextSpan(text: value.isEmpty ? ' ' : value, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();

    final double contentWidth = painter.width + (_isEditingPseudo ? 20 : 0);
    return contentWidth.clamp(_minPseudoWidth, maxWidth).toDouble();
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
                    /// Pseudo editable au clic avec largeur dynamique
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double iconSize =
                              theme.textTheme.titleMedium?.fontSize ?? 16;
                          final double maxPseudoWidth =
                              (constraints.maxWidth - iconSize - 8)
                                  .clamp(_minPseudoWidth, double.infinity)
                                  .toDouble();
                          final double pseudoWidth = _computePseudoWidth(
                            context: context,
                            style: theme.textTheme.titleMedium,
                            maxWidth: maxPseudoWidth,
                          );

                          return Row(
                            children: [
                              SizedBox(
                                width: pseudoWidth,
                                child: _isEditingPseudo
                                    ? TextField(
                                        controller: _pseudoController,
                                        focusNode: _pseudoFocusNode,
                                        autofocus: true,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (_) => setState(() {}),
                                        onSubmitted: (_) => _commitPseudo(),
                                        style: theme.textTheme.titleMedium,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          enabledBorder:
                                              const UnderlineInputBorder(),
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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                              ),

                              const SizedBox(width: 8),

                              /// Edit profile button
                              GestureDetector(
                                onTap: _startPseudoEditing,
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  Icons.edit,
                                  color: theme.iconTheme.color,
                                  size: iconSize,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
