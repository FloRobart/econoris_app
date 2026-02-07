import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/operation.dart';
import '../../../routing/app_routes.dart';
import '../../../widgets/add_operation_fab.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../pages/calendar_page.dart';
import '../../../widgets/monthly_totals_banner.dart';
import '../../../widgets/operation_dialogs.dart';
import '../../../widgets/operations_chart.dart';
import '../../../widgets/operations_table.dart';
import 'operations_view_model.dart';

/// Vue principale des operations (MVVM + Riverpod).
class OperationsPage extends ConsumerWidget {
  const OperationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Etat observe depuis le ViewModel.
    final state = ref.watch(operationsControllerProvider);
    final controller = ref.read(operationsControllerProvider.notifier);

    // Donnees derivees pour l'affichage.
    final filtered = controller.filteredSortedOperations();
    final totals = controller.buildTotals();
    final categories = controller.categories();
    final totalPages = controller.totalPages(filtered.length);
    final pageItems = controller.pageItems(filtered);

    // Helper pour le label de mois.
    String monthLabel(int y, int m) =>
        DateFormat.yMMMM('fr_FR').format(DateTime(y, m));

    Future<void> openDetail(Operation op) async {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => OperationDetailDialog(operation: op),
      );
      if (result == 'deleted' || result == 'updated') {
        await controller.refresh();
      }
    }

    return AppScaffold(
      currentIndex: 1,
      onProfilePressed: (ctx) {
        Navigator.of(ctx).pushNamed(AppRoutes.profile).then(
              (_) => controller.refresh(),
            );
      },
      floatingActionButton: AddOperationFab(
        operations: state.operations,
        onOperationCreated: controller.handleOperationCreated,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Banniere de totaux mensuels.
                      MonthlyTotalsBanner(
                        revenueLabel: 'Revenu '
                            '${monthLabel(totals.revenueYear, totals.revenueMonth)}',
                        expenseLabel: 'Dépense '
                            '${monthLabel(totals.expenseYear, totals.expenseMonth)}',
                        revenueAmount: totals.revenueAmount,
                        expenseAmount: totals.expenseAmount,
                      ),

                      const SizedBox(height: 12),

                      // Carte du graphique + selecteur de type.
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).cardColor.withAlpha(
                                                (0.95 * 255).toInt(),
                                              ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButton<String>(
                                      value: state.chartType,
                                      dropdownColor:
                                          Theme.of(context).cardColor,
                                      underline: const SizedBox.shrink(),
                                      items: const ['line', 'bar', 'pie']
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          controller.setChartType(v);
                                        }
                                      },
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${filtered.length} operations',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 220,
                                child: OperationsChart(
                                  operations: filtered,
                                  chartType: state.chartType,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Controles: recherche + tri.
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Rechercher par nom...',
                              ),
                              onChanged: controller.setSearch,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            tooltip: 'Tri',
                            onSelected: controller.setSortField,
                            child: const Row(
                              children: [
                                Icon(Icons.sort),
                                SizedBox(width: 6),
                                Text('Tri'),
                              ],
                            ),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'operations_date',
                                child: Text('Date'),
                              ),
                              PopupMenuItem(
                                value: 'operations_name',
                                child: Text('Nom'),
                              ),
                              PopupMenuItem(
                                value: 'operations_amount',
                                child: Text('Montant'),
                              ),
                              PopupMenuItem(
                                value: 'operations_id',
                                child: Text('ID'),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              state.sortAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                            onPressed: controller.toggleSortDirection,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Filtres: categorie + validation.
                      Row(
                        children: [
                          const Text('Categorie:'),
                          const SizedBox(width: 6),
                          DropdownButton<String>(
                            value: state.categoryFilter,
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                controller.setCategoryFilter(v);
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text('Valide:'),
                          const SizedBox(width: 6),
                          DropdownButton<String>(
                            value: state.validateFilter,
                            items: const ['Tous', 'Validé', 'Non validé']
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                controller.setValidateFilter(v);
                              }
                            },
                          ),
                        ],
                      ),

                      // Toggle table / calendrier.
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: controller.toggleTableView,
                            child: Text(
                              state.tableView
                                  ? 'Vue calendrier'
                                  : 'Vue tableau',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tableau ou calendrier selon l'etat.
                      if (state.tableView) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Card(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: OperationsTable(
                                  operations: pageItems,
                                  columns: const [
                                    'date',
                                    'name',
                                    'amount',
                                    'validated',
                                  ],
                                  onRowTap: openDetail,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        CalendarPage(
                          operations: filtered,
                          onOperationTap: openDetail,
                          noScroll: true,
                        ),
                      ],

                      // Pagination uniquement pour le tableau.
                      if (state.tableView)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: state.page > 1
                                  ? () => controller.setPage(state.page - 1)
                                  : null,
                            ),
                            Text('Page ${state.page} / $totalPages'),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: state.page < totalPages
                                  ? () => controller.setPage(state.page + 1)
                                  : null,
                            ),
                          ],
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
