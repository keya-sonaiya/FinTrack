  import 'package:flutter/material.dart';
  import 'package:fl_chart/fl_chart.dart';
  import 'package:intl/intl.dart';
  import '../models/transaction_model.dart';
  import '../services/supabase_service.dart';

  class ChartScreen extends StatefulWidget {
    const ChartScreen({super.key});

    @override
    State<ChartScreen> createState() => _ChartScreenState();
  }

  class _ChartScreenState extends State<ChartScreen> {
    String selectedType = 'expense';
    String timeMode = 'Month';
    String selectedPeriod = DateFormat('MMM').format(DateTime.now());
    int selectedYear = DateTime.now().year;

    final SupabaseService _supabaseService = SupabaseService();

    List<String> getPeriodOptions(List<TransactionModel> transactions) {
      if (timeMode == 'Week') {
        return getWeekRangesForMonth(selectedYear);
      } else if (timeMode == 'Month') {
        return List.generate(12, (index) =>
            DateFormat('MMM').format(DateTime(selectedYear, index + 1)));
      } else {
        final years = transactions.map((e) => e.date.year).toSet().toList()..sort();
        return years.map((e) => e.toString()).toList();
      }
    }

    List<String> getWeekRangesForMonth(int year) {
      final now = DateTime.now();
      final firstDay = DateTime(year, now.month, 1);
      final lastDay = DateTime(year, now.month + 1, 0);

      List<String> weeks = [];
      DateTime start = firstDay;

      while (start.isBefore(lastDay)) {
        final end = start.add(const Duration(days: 6));
        final weekEnd = end.isAfter(lastDay) ? lastDay : end;
        weeks.add('${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(weekEnd)}');
        start = weekEnd.add(const Duration(days: 1));
      }

      return weeks;
    }

    String capitalize(String s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Statistics", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500)),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: FutureBuilder<List<TransactionModel>>(
          future: _supabaseService.getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final transactions = snapshot.data ?? [];

            final periodOptions = getPeriodOptions(transactions);
            if (!periodOptions.contains(selectedPeriod) && periodOptions.isNotEmpty) {
              selectedPeriod = periodOptions.first;
            }

            final filteredTx = transactions.where((tx) {
              if (tx.type != selectedType) return false;

              if (timeMode == 'Month') {
                return DateFormat('MMM').format(tx.date) == selectedPeriod &&
                    tx.date.year == selectedYear;
              } else if (timeMode == 'Year') {
                return tx.date.year.toString() == selectedPeriod;
              } else {
                final parts = selectedPeriod.split(' - ');
                if (parts.length != 2) return false;

                final start = DateFormat('d MMM').parse(parts[0]);
                final end = DateFormat('d MMM').parse(parts[1]);

                final txDay = DateTime(selectedYear, tx.date.month, tx.date.day);
                final startFull = DateTime(selectedYear, start.month, start.day);
                final endFull = DateTime(selectedYear, end.month, end.day);

                return !txDay.isBefore(startFull) && !txDay.isAfter(endFull);
              }
            }).toList();

            final Map<String, double> categoryTotals = {};
            double total = 0;
            for (var tx in filteredTx) {
              categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
              total += tx.amount;
            }

            final categoryNames = categoryTotals.keys.toList();
            final categoryColors = [
              Colors.blue,
              const Color.fromARGB(255, 209, 122, 116),
              const Color.fromARGB(255, 207, 124, 222),
              Colors.teal,
              Colors.brown,
              const Color.fromARGB(255, 235, 188, 118),
              const Color.fromARGB(255, 90, 98, 145)
            ];

            final years = transactions.map((e) => e.date.year).toSet().toList()..sort();

            return Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Type:", style: TextStyle(fontSize: 17)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedType,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(
                                  value: 'income',
                                  child: Row(
                                    children: const [
                                    
                                    
                                      Text("Income"),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'expense',
                                  child: Row(
                                    children: const [
                                      
                                    
                                      Text("Expense"),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => selectedType = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("View By:", style: TextStyle(fontSize: 17)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: timeMode,
                              
                              isExpanded: true,
                              items: ['Week', 'Month', 'Year'].map((e) =>
                                DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    timeMode = val;
                                    final options = getPeriodOptions(transactions);
                                    selectedPeriod = options.isNotEmpty ? options.first : '';
                                    if (timeMode == 'Year') {
                                      selectedYear = DateTime.now().year;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (timeMode != 'Year')
                        Row(
                          children: [
                            const Text("Year:", style: TextStyle(fontSize: 17)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButton<int>(
                                value: years.contains(selectedYear) ? selectedYear : null,
                                isExpanded: true,
                                hint: const Text("No Data"),
                                items: years.map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                                onChanged: years.isEmpty
                                    ? null
                                    : (val) {
                                        if (val != null) {
                                          setState(() {
                                            selectedYear = val;
                                            final options = getPeriodOptions(transactions);
                                            selectedPeriod = options.isNotEmpty ? options.first : '';
                                          });
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          const Text("Period:", style: TextStyle(fontSize: 17)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedPeriod,
                              isExpanded: true,
                              items: periodOptions.map((e) =>
                                DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => selectedPeriod = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (total == 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      
                      SizedBox(height: 10),
                      Text("No data available", style: TextStyle(fontSize: 17)),
                    ],
                  )
                else
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: List.generate(categoryTotals.length, (index) {
                            final category = categoryNames[index];
                            final value = categoryTotals[category]!;
                            final percentage = ((value / total) * 100).toStringAsFixed(1);
                            return PieChartSectionData(
                              color: categoryColors[index % categoryColors.length],
                              value: value,
                              title: "$percentage %",
                              radius: 100,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (total != 0)
                  Expanded(
                    child: ListView.builder(
                      itemCount: categoryTotals.length,
                      itemBuilder: (context, index) {
                        final category = categoryNames[index];
                        final value = categoryTotals[category]!;
                        final percentage = ((value / total) * 100).toStringAsFixed(1);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: categoryColors[index % categoryColors.length],
                            radius: 8,
                          ),
                          title: Text(category,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          trailing: Text("₹${value.toStringAsFixed(2)} • $percentage%",
                              style: TextStyle(fontSize: 14, color:Colors.grey)),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }
  }
