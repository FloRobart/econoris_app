// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// date formatting handled by SubscriptionsTable

import '../models/subscription.dart';
import '../services/global_data_impl.dart';
import '../widgets/app_scaffold.dart';
import '../navigation/app_routes.dart';
import '../widgets/subscriptions_chart.dart';
// calendar view not used for subscriptions (simple list used instead)
import '../widgets/subscription_dialogs.dart';
import '../widgets/add_operation_fab.dart';
import '../widgets/subscriptions_table.dart';
import '../widgets/monthly_totals_banner.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});
  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<Subscription> _subscriptions = [];
  String? _jwt;
  bool _loading = false;
  String? _error;

  // UI state
  String _chartType = 'line';
  bool _tableView = true;
  String _search = '';
  String _sortField = 'start_date';
  bool _sortAsc = false;
  String _categoryFilter = 'Tous';
  String _activeFilter = 'Tous'; // Tous / Actif / Inactif

  // Pagination
  int _page = 1;
  static const int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    setState(() { _jwt = sp.getString('jwt'); });
    if (_jwt != null) {
      setState(() { _loading = true; _error = null; });
      try {
        await GlobalData.instance.ensureData(_jwt!);
        setState(() { _subscriptions = GlobalData.instance.subscriptions ?? []; _loading = false; _page = 1; });
      } catch (e) {
        setState(() { _error = e.toString(); _loading = false; });
      }
    }
  }

  // Data is fetched from GlobalData; use _init or the RefreshIndicator to
  // refresh the central store.

  // no-op getter removed — filtering & sorting done in build

  void _openDetail(Subscription s) async {
    final result = await showDialog<String>(context: context, builder: (_) => SubscriptionDetailDialog(subscription: s));
    if (result == 'deleted' || result == 'updated') await _init();
  }

  @override
  Widget build(BuildContext context) {
    final subsFiltered = _subscriptions.where((sub) {
      if (_categoryFilter != 'Tous' && sub.category != _categoryFilter) return false;
      if (_activeFilter == 'Actif' && !sub.active) return false;
      if (_activeFilter == 'Inactif' && sub.active) return false;
      if (_search.isNotEmpty) {
        final s = _search.toLowerCase();
        return sub.label.toLowerCase().contains(s) || (sub.source ?? '').toLowerCase().contains(s) || (sub.destination ?? '').toLowerCase().contains(s);
      }
      return true;
    }).toList();

    subsFiltered.sort((a, b) {
      int res = 0;
      switch (_sortField) {
        case 'operations_amount': res = a.amount.compareTo(b.amount); break;
        case 'operations_name': res = a.label.compareTo(b.label); break;
        case 'start_date': res = a.startDate.compareTo(b.startDate); break;
        case 'operations_id': res = a.id.compareTo(b.id); break;
        default: res = a.startDate.compareTo(b.startDate);
      }
      return _sortAsc ? res : -res;
    });

    final ops = subsFiltered; // alias for naming below

    // Helper to convert a subscription amount to its monthly equivalent.
    double monthlyEquivalent(Subscription s) {
      final int interval = (s.intervalValue <= 0) ? 1 : s.intervalValue;
      const double daysPerMonth = 30.436875; // average days per month
      const double weeksPerMonth = 4.348125; // average weeks per month

      switch (s.intervalUnit) {
        case 'days':
          return s.amount * (daysPerMonth / interval);
        case 'weeks':
          return s.amount * (weeksPerMonth / interval);
        case 'months':
        default:
          return s.amount / interval;
      }
    }

  // Only include negative subscriptions (expenses) in the total
  final double monthlyTotal = ops
      .where((s) => s.amount < 0)
      .fold(0.0, (double acc, Subscription s) => acc + monthlyEquivalent(s));

  // current date helpers for banner
  final now = DateTime.now();
  final currentYear = now.year;
  final currentMonth = now.month;

  // --- Monthly totals for subscriptions (adapted banner) ---
  // compute monthly revenue and expense equivalents from subscriptions
  final double revenueCurrent = ops
      .where((s) => s.amount > 0)
      .fold(0.0, (double acc, Subscription s) => acc + monthlyEquivalent(s));

  final double expenseCurrent = ops
      .where((s) => s.amount < 0)
      .fold(0.0, (double acc, Subscription s) => acc + monthlyEquivalent(s).abs());

  int displayRevenueYear = currentYear;
  int displayRevenueMonth = currentMonth;
  double revenueToShow = revenueCurrent;
  if (revenueCurrent == 0) {
    if (currentMonth == 1) {
      displayRevenueMonth = 12;
      displayRevenueYear = currentYear - 1;
    } else {
      displayRevenueMonth = currentMonth - 1;
      displayRevenueYear = currentYear;
    }
    // for subscriptions, use same ops set but filter by month/year of startDate (approximation)
    revenueToShow = _subscriptions
        .where((s) => s.startDate.year == displayRevenueYear && s.startDate.month == displayRevenueMonth && s.amount > 0)
        .fold(0.0, (double acc, Subscription s) => acc + monthlyEquivalent(s));
  }

  String monthLabel(int y, int m) => DateFormat.yMMMM('fr_FR').format(DateTime(y, m));
  // Make Theme available for the banner and other UI parts
  final theme = Theme.of(context);

  // Use MonthlyTotalsBanner (defined in widgets) instead of local Card

  final totalPages = (ops.length / _pageSize).ceil().clamp(1, 9999);
  final pageItems = ops.skip((_page - 1) * _pageSize).take(_pageSize).toList();
  final categories = ['Tous'] + _subscriptions.map((e) => e.category).toSet().toList();

    return AppScaffold(
      // Subscriptions tab index is 2 (0: Accueil, 1: Opérations, 2: Abonnements, 3: Prêts, 4: Horaires)
      currentIndex: 2,
      onProfilePressed: (ctx) => Navigator.of(ctx).pushNamed(AppRoutes.profile).then((_) => _init()),
      floatingActionButton: AddOperationFab(
        subscriptions: _subscriptions,
        onOperationCreated: (op) {
          // Subscriptions page does not keep a local operations list;
          // just give quick feedback to the user when an operation is created.
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
        },
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: () async {
          await GlobalData.instance.fetchAll(_jwt ?? '');
          setState(() { _subscriptions = GlobalData.instance.subscriptions ?? []; _page = 1; });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_error != null) Padding(padding: const EdgeInsets.only(bottom:8.0), child: Text(_error!, style: const TextStyle(color: Colors.red))),

              // Banner with monthly totals (subscriptions)
              MonthlyTotalsBanner(
                revenueLabel: 'Revenu ${monthLabel(displayRevenueYear, displayRevenueMonth)}',
                expenseLabel: 'Dépense ${monthLabel(currentYear, currentMonth)}',
                revenueAmount: revenueToShow,
                expenseAmount: expenseCurrent,
              ),

              const SizedBox(height: 12),

              // Chart card with chart type selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: theme.cardColor.withAlpha((0.95 * 255).toInt()), borderRadius: BorderRadius.circular(6)),
                        child: DropdownButton<String>(
                          value: _chartType,
                          dropdownColor: theme.cardColor,
                          underline: const SizedBox.shrink(),
                          items: ['line', 'bar', 'pie'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _chartType = v!),
                        ),
                      ),
                      const Spacer(),
                      Text('${ops.length} abonnements', style: theme.textTheme.bodyMedium),
                    ]),
                    const SizedBox(height: 8),
                    SizedBox(height: 220, child: SubscriptionsChart(subscriptions: ops, chartType: _chartType)),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // Controls: search, filters, sort
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher par nom...'),
                    onChanged: (v) => setState(() { _search = v; _page = 1; }),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Tri',
                  onSelected: (v) => setState(() { _sortField = v; }),
                  child: const Row(children: [Icon(Icons.sort), SizedBox(width:6), Text('Tri')]),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'start_date', child: Text('Date')),
                      PopupMenuItem(value: 'operations_name', child: Text('Nom')),
                      PopupMenuItem(value: 'operations_amount', child: Text('Montant')),
                      PopupMenuItem(value: 'operations_id', child: Text('ID')),
                    ],
                ),
                IconButton(icon: Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward), onPressed: () => setState(() => _sortAsc = !_sortAsc)),
              ]),

              const SizedBox(height: 8),

              Row(children: [
                const Text('Catégorie:'),
                const SizedBox(width: 6),
                DropdownButton<String>(value: _categoryFilter, items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() { _categoryFilter = v!; _page = 1; })),
                const SizedBox(width: 12),
                const Text('Actif:'),
                const SizedBox(width: 6),
                DropdownButton<String>(value: _activeFilter, items: ['Tous', 'Actif', 'Inactif'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() { _activeFilter = v!; _page = 1; })),
              ]),

              // Toggle button moved to its own line to avoid overflow on small screens
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () => setState(() => _tableView = !_tableView), child: Text(_tableView ? 'Vue calendrier' : 'Vue tableau'))),
              ),

              const SizedBox(height: 12),

              // List / table (toggle between DataTable and calendar view)
              if (_tableView) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Card(
                      child: SingleChildScrollView(
                            // horizontal scrolling for wide tables; Card will now size to child
                            scrollDirection: Axis.horizontal,
                            child: SubscriptionsTable(
                              subscriptions: pageItems,
                              // pagination already applied by caller
                              columns: const ['start_date', 'name', 'amount', 'active'],
                              onRowTap: (o) => _openDetail(o),
                            ),
                          ),
                    ),
                  ),
                ),
              ] else ...[
                // Simple list view of subscriptions when not in table mode
                Card(
                  child: Column(children: pageItems.map((s) => ListTile(
                    title: Text(s.label),
                    subtitle: Text('${s.startDate.toIso8601String()} • ${s.category}'),
                    trailing: Text(s.amount.toStringAsFixed(2)),
                    onTap: () => _openDetail(s),
                  )).toList()),
                ),
              ],

              // Pagination controls (mobile-friendly) - only for table view
              if (_tableView)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: _page > 1 ? () => setState(() => _page--) : null),
                  Text('Page $_page / $totalPages'),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: _page < totalPages ? () => setState(() => _page++) : null),
                ]),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }
}
