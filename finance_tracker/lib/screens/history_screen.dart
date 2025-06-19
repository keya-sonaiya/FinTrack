import 'package:finance_tracker/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

Future<void> _fetchTransactions() async {
  setState(() => _loading = true);
  final transactions = await SupabaseService().getTransactions();
  setState(() {
    _allTransactions = transactions;
    _filteredTransactions = transactions;
    _loading = false;
  });
}


  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredTransactions = _allTransactions;
      });
    } else {
      setState(() {
        _filteredTransactions = _allTransactions.where((tx) {
          final titleMatch = tx.title.toLowerCase().contains(query);
          final amountMatch = tx.amount.toString().contains(query);
          final typeMatch = tx.type.toLowerCase().contains(query);
          return titleMatch || amountMatch || typeMatch;
        }).toList();
      });
    }
  }

  Map<String, List<TransactionModel>> _groupTransactionsByMonth(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in transactions) {
      try {
        final month = DateFormat.yMMMM().format(tx.date);
        if (!grouped.containsKey(month)) {
          grouped[month] = [];
        }
        grouped[month]!.add(tx);
      } catch (e) {
        const fallbackMonth = 'Invalid Date';
        grouped.putIfAbsent(fallbackMonth, () => []).add(tx);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupTransactionsByMonth(_filteredTransactions);

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        try {
          final aDate = DateFormat.yMMMM().parse(a.key);
          final bDate = DateFormat.yMMMM().parse(b.key);
          return bDate.compareTo(aDate);
        } catch (e) {
          if (a.key == 'Invalid Date') return 1;
          if (b.key == 'Invalid Date') return -1;
          return b.key.compareTo(a.key);
        }
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
child: _loading
    ? const Center(
        child: CircularProgressIndicator(color: Colors.green),
      )
    : _allTransactions.isEmpty

          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "No transactions yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Transaction"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by title, amount or type',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredTransactions.isEmpty
                        ? const Center(child: Text("No matching transactions found"))
                        : ListView.builder(
                            itemCount: sortedEntries.length,
                            itemBuilder: (context, index) {
                              final entry = sortedEntries[index];
                              final month = entry.key;
                              final txs = entry.value;

                              final monthTotal = txs.fold(
                                0.0,
                                (sum, tx) => sum + (tx.type == 'income' ? tx.amount : -tx.amount),
                              );

                              return ExpansionTile(
                                title: Text(
                                  month,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                ),
                                trailing: Text(
                                  "₹${monthTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: monthTotal >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                children: List.generate(txs.length, (i) {
                                  final tx = txs[i];
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: Duration(milliseconds: 600 + (i * 100)),
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 20 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      title: Text(tx.title),
                                      subtitle: Text(DateFormat('dd MMM yyyy').format(tx.date)),
                                      trailing: Text(
                                        "${tx.type == 'income' ? '+' : '-'} ₹${tx.amount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: tx.type == 'income' ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddTransactionScreen(transaction: tx),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
