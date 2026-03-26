import 'dart:async';

import 'package:econoris_app/config/constantes.dart';
import 'package:econoris_app/domain/models/operations/create/operation_create.dart';
import 'package:econoris_app/ui/core/ui/forms/amount_field.dart';
import 'package:econoris_app/ui/core/ui/forms/amount_type_switch_field.dart';
import 'package:econoris_app/ui/core/ui/forms/categories_field.dart';
import 'package:econoris_app/ui/core/ui/forms/date_field.dart';
import 'package:econoris_app/ui/core/ui/forms/label_field.dart';
import 'package:econoris_app/ui/core/ui/forms/submit_button.dart';
import 'package:flutter/material.dart';
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
    final draftAmount = prefs.getString(Constantes.draftOperationAmountKey);
    final draftLabel = prefs.getString(Constantes.draftOperationLabelKey);
    final draftDateRaw = prefs.getString(Constantes.draftOperationDateKey);
    final draftCategory = prefs.getString(Constantes.draftOperationCategoryKey);
    final draftIsExpense = prefs.getBool(Constantes.draftOperationIsExpenseKey);

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
      await prefs.setString(Constantes.draftOperationAmountKey, draftAmount);
      _lastSavedAmount = draftAmount;
    }
    if (_lastSavedLabel != draftLabel) {
      await prefs.setString(Constantes.draftOperationLabelKey, draftLabel);
      _lastSavedLabel = draftLabel;
    }
    if (_lastSavedDate != draftDate) {
      await prefs.setString(Constantes.draftOperationDateKey, draftDate);
      _lastSavedDate = draftDate;
    }
    if (_lastSavedCategory != draftCategory) {
      await prefs.setString(Constantes.draftOperationCategoryKey, draftCategory);
      _lastSavedCategory = draftCategory;
    }
    if (_lastSavedIsExpense != draftIsExpense) {
      await prefs.setBool(Constantes.draftOperationIsExpenseKey, draftIsExpense);
      _lastSavedIsExpense = draftIsExpense;
    }
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constantes.draftOperationAmountKey);
    await prefs.remove(Constantes.draftOperationLabelKey);
    await prefs.remove(Constantes.draftOperationDateKey);
    await prefs.remove(Constantes.draftOperationCategoryKey);
    await prefs.remove(Constantes.draftOperationIsExpenseKey);

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

    final parsedAmount = parseAmountForField(_amountController.text);
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
                AmountTypeSwitchField(
                  isExpense: _isExpense,
                  onChanged: (value) {
                    setState(() {
                      _isExpense = value;
                    });
                    unawaited(_saveDraft());
                  },
                ),
                const SizedBox(height: 16),
                AmountField(controller: _amountController),
                const SizedBox(height: 16),
                LabelField(controller: _labelController, hintText: 'Nom de l\'operation'),
                const SizedBox(height: 16),
                CategoriesField(
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
                DateField(selectedDate: _selectedDate, onTap: _pickDate),
                const SizedBox(height: 20),
                SubmitButton(onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatAmountWithoutSign(double amount) {
  return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
}
