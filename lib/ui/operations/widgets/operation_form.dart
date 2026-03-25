import 'dart:async';

import 'package:econoris_app/config/constantes.dart';
import 'package:econoris_app/domain/models/operations/create/operation_create.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Formulaire de création d'une opération.
class OperationCreateForm extends StatefulWidget {
  const OperationCreateForm({super.key, this.operationCreate});

  final OperationCreate? operationCreate;

  @override
  State<OperationCreateForm> createState() {
    return _OperationCreateFormState();
  }
}

/// State du formulaire de création d'une opération.
class _OperationCreateFormState extends State<OperationCreateForm> {
  static const _draftAmountKey = 'operation_create_draft_amount';
  static const _draftLabelKey = 'operation_create_draft_label';
  static const _draftDateKey = 'operation_create_draft_date';
  static const _draftCategoryKey = 'operation_create_draft_category';
  static const _draftIsExpenseKey = 'operation_create_draft_is_expense';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _labelController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _isExpense;
  bool _isRestoringDraft = false;
  bool _isSubmitting = false;
  Timer? _draftSaveDebounceTimer;

  String? _lastSavedAmount;
  String? _lastSavedLabel;
  String? _lastSavedDate;
  String? _lastSavedCategory;
  bool? _lastSavedIsExpense;

  @override
  void initState() {
    super.initState();

    final initialOperation = widget.operationCreate;
    final initialAmount = initialOperation?.amount;

    _isExpense = initialAmount == null ? true : initialAmount <= 0;
    _amountController = TextEditingController(
      text: initialAmount == null
          ? ''
          : _formatAmountWithoutSign(initialAmount.abs()),
    );
    _labelController = TextEditingController(
      text: initialOperation?.label ?? '',
    );
    _selectedDate = initialOperation?.levyDate ?? DateTime.now();

    final firstCategory = Constantes.operationCategories.first;
    _selectedCategory =
        Constantes.operationCategories.contains(initialOperation?.category)
        ? initialOperation!.category
        : firstCategory;

    _amountController.addListener(_onDraftValueChanged);
    _labelController.addListener(_onDraftValueChanged);
    unawaited(_restoreDraft());
  }

  @override
  void dispose() {
    _draftSaveDebounceTimer?.cancel();
    unawaited(_saveDraft());
    _amountController.removeListener(_onDraftValueChanged);
    _labelController.removeListener(_onDraftValueChanged);
    _amountController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _onDraftValueChanged() {
    _scheduleDebouncedDraftSave();
  }

  void _scheduleDebouncedDraftSave() {
    if (widget.operationCreate != null || _isRestoringDraft || _isSubmitting) {
      return;
    }

    _draftSaveDebounceTimer?.cancel();
    _draftSaveDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      unawaited(_saveDraft());
    });
  }

  Future<void> _restoreDraft() async {
    if (widget.operationCreate != null) {
      return;
    }

    _isRestoringDraft = true;
    final prefs = await SharedPreferences.getInstance();
    final draftAmount = prefs.getString(_draftAmountKey);
    final draftLabel = prefs.getString(_draftLabelKey);
    final draftDateRaw = prefs.getString(_draftDateKey);
    final draftCategory = prefs.getString(_draftCategoryKey);
    final draftIsExpense = prefs.getBool(_draftIsExpenseKey);

    _lastSavedAmount = draftAmount;
    _lastSavedLabel = draftLabel;
    _lastSavedDate = draftDateRaw;
    _lastSavedCategory = draftCategory;
    _lastSavedIsExpense = draftIsExpense;

    final parsedDate = draftDateRaw == null
        ? null
        : DateTime.tryParse(draftDateRaw);
    final resolvedCategory =
        Constantes.operationCategories.contains(draftCategory)
        ? draftCategory
        : null;

    if (!mounted) {
      _isRestoringDraft = false;
      return;
    }

    setState(() {
      if (draftAmount != null) {
        _amountController.text = draftAmount;
      }
      if (draftLabel != null) {
        _labelController.text = draftLabel;
      }
      if (parsedDate != null) {
        _selectedDate = parsedDate;
      }
      if (resolvedCategory != null) {
        _selectedCategory = resolvedCategory;
      }
      if (draftIsExpense != null) {
        _isExpense = draftIsExpense;
      }
    });

    _isRestoringDraft = false;
  }

  Future<void> _saveDraft() async {
    if (widget.operationCreate != null || _isRestoringDraft || _isSubmitting) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final draftAmount = _amountController.text;
    final draftLabel = _labelController.text;
    final draftDate = _selectedDate.toIso8601String();
    final draftCategory = _selectedCategory;
    final draftIsExpense = _isExpense;

    if (_lastSavedAmount != draftAmount) {
      await prefs.setString(_draftAmountKey, draftAmount);
      _lastSavedAmount = draftAmount;
    }
    if (_lastSavedLabel != draftLabel) {
      await prefs.setString(_draftLabelKey, draftLabel);
      _lastSavedLabel = draftLabel;
    }
    if (_lastSavedDate != draftDate) {
      await prefs.setString(_draftDateKey, draftDate);
      _lastSavedDate = draftDate;
    }
    if (_lastSavedCategory != draftCategory) {
      await prefs.setString(_draftCategoryKey, draftCategory);
      _lastSavedCategory = draftCategory;
    }
    if (_lastSavedIsExpense != draftIsExpense) {
      await prefs.setBool(_draftIsExpenseKey, draftIsExpense);
      _lastSavedIsExpense = draftIsExpense;
    }
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftAmountKey);
    await prefs.remove(_draftLabelKey);
    await prefs.remove(_draftDateKey);
    await prefs.remove(_draftCategoryKey);
    await prefs.remove(_draftIsExpenseKey);

    _lastSavedAmount = null;
    _lastSavedLabel = null;
    _lastSavedDate = null;
    _lastSavedCategory = null;
    _lastSavedIsExpense = null;
  }

  Future<DateTime?> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return null;
    }

    setState(() {
      _selectedDate = pickedDate;
    });

    unawaited(_saveDraft());

    return pickedDate;
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final parsedAmount = _parseAmount(_amountController.text);
    if (parsedAmount == null) {
      return;
    }

    final signedAmount = _isExpense ? -parsedAmount.abs() : parsedAmount.abs();
    final operationCreate = OperationCreate(
      levyDate: _selectedDate,
      label: _labelController.text.trim(),
      amount: signedAmount,
      category: _selectedCategory,
    );

    _isSubmitting = true;
    unawaited(_clearDraft());
    Navigator.of(context).pop(operationCreate);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OperationTypeSwitchField(
                  isExpense: _isExpense,
                  onChanged: (value) {
                    setState(() {
                      _isExpense = value;
                    });
                    unawaited(_saveDraft());
                  },
                ),
                const SizedBox(height: 16),
                AmountFormField(controller: _amountController),
                const SizedBox(height: 16),
                LabelFormField(controller: _labelController),
                const SizedBox(height: 16),
                CategoriesHorizontalField(
                  categories: Constantes.operationCategories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    unawaited(_saveDraft());
                  },
                ),
                const SizedBox(height: 16),
                DateFormField(selectedDate: _selectedDate, onTap: _pickDate),
                const SizedBox(height: 20),
                SubmitOperationButton(onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OperationTypeSwitchField extends StatelessWidget {
  const OperationTypeSwitchField({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedType = isExpense
        ? OperationType.expense
        : OperationType.income;

    return Row(
      children: [
        Expanded(
          child: Text(
            isExpense ? 'Depense' : 'Revenu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isExpense ? AppTheme.errorColor : AppTheme.successColor,
            ),
          ),
        ),
        SegmentedButton<OperationType>(
          segments: const [
            ButtonSegment<OperationType>(
              value: OperationType.expense,
              icon: Icon(Icons.arrow_downward_rounded),
              label: Text('Depense'),
            ),
            ButtonSegment<OperationType>(
              value: OperationType.income,
              icon: Icon(Icons.arrow_upward_rounded),
              label: Text('Revenu'),
            ),
          ],
          selected: {selectedType},
          style: SegmentedButton.styleFrom(
            selectedForegroundColor: isExpense
                ? AppTheme.errorColor
                : AppTheme.successColor,
          ),
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            if (selection.isEmpty) {
              return;
            }

            onChanged(selection.first == OperationType.expense);
          },
        ),
      ],
    );
  }
}

enum OperationType { expense, income }

class AmountFormField extends StatelessWidget {
  const AmountFormField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: const [AmountInputFormatter()],
      decoration: const InputDecoration(
        labelText: 'Montant',
        hintText: 'Ex: 42.50',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) {
          return 'Le montant est obligatoire';
        }

        final parsedAmount = _parseAmount(trimmedValue);
        if (parsedAmount == null) {
          return 'Montant invalide';
        }

        if (parsedAmount <= 0) {
          return 'Le montant doit etre superieur a 0';
        }

        return null;
      },
    );
  }
}

class LabelFormField extends StatelessWidget {
  const LabelFormField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      maxLength: 200,
      decoration: const InputDecoration(
        labelText: 'Nom',
        hintText: 'Nom de l\'operation',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) {
          return 'Le nom est obligatoire';
        }

        return null;
      },
    );
  }
}

class CategoriesHorizontalField extends StatelessWidget {
  const CategoriesHorizontalField({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

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
              scrollDirection: Axis.horizontal,
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

class DateFormField extends StatelessWidget {
  const DateFormField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  final DateTime selectedDate;
  final Future<DateTime?> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: (value) {
        if (value == null) {
          return 'La date est obligatoire';
        }

        return null;
      },
      builder: (state) {
        final dateText = MaterialLocalizations.of(
          context,
        ).formatCompactDate(selectedDate);

        return InkWell(
          onTap: () async {
            final pickedDate = await onTap();
            if (pickedDate != null) {
              state.didChange(pickedDate);
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
              errorText: state.errorText,
            ),
            child: Text(dateText),
          ),
        );
      },
    );
  }
}

class SubmitOperationButton extends StatelessWidget {
  const SubmitOperationButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: const Text('Valider'),
    );
  }
}

class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();

  static final _validPattern = RegExp(r'^\d*([\.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _validPattern.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

double? _parseAmount(String rawAmount) {
  final normalized = rawAmount.trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}

String _formatAmountWithoutSign(double amount) {
  return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
}
