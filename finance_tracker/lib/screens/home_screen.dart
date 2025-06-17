import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/summary_card.dart';
import 'add_transaction_screen.dart';
import 'charts_screen.dart';
import 'history_screen.dart';
import 'auth_screen.dart';
import '../models/transaction_model.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int _currentIndex = 0;

  Map<String, dynamic>? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await _supabaseService.getUserProfile();
      setState(() {
        _profile = profile;
        _loadingProfile = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch profile: $e');
      setState(() => _loadingProfile = false);
    }
  }

  Future<List<TransactionModel>> _loadTransactions() async {
    List<TransactionModel> transactions =
        await _supabaseService.getTransactions();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final userEmail =
        Supabase.instance.client.auth.currentUser?.email ?? 'user@example.com';
    final username = _profile?['username'] ?? 'User';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    final screens = [
      _buildHomeTab(),
      const ChartScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
    appBar: _currentIndex == 0
    ? AppBar(
        title: const Text(
          'FinTrack',
          style: TextStyle(
            fontSize: 21,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.value == ThemeMode.dark
                  ? Icons.light_mode // show sun
                  : Icons.dark_mode, // show moon
              color: Colors.white,
            ),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      )
    : null,


      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _loadingProfile
                ? const DrawerHeader(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                )
                : Container(
                  color: Colors.green,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 40, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Username: $username',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: $userEmail',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
// SwitchListTile(
//   title: const Text(
//     'Dark Mode',
//     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//   ),
//   secondary: const Icon(Icons.dark_mode),
//   activeColor: Colors.green,
//   value: themeNotifier.value == ThemeMode.dark,
//   onChanged: (val) {
//     themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
//   },
// ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );

                if (shouldLogout == true) {
                  await Supabase.instance.client.auth.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),

      body: screens[_currentIndex],

      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

 Widget _buildHomeTab() {
  return FutureBuilder<List<TransactionModel>>(
    future: _loadTransactions(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.green),
        );
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      final transactions = snapshot.data ?? [];

      double income = 0;
      double expense = 0;

      for (var transaction in transactions) {
        if (transaction.type == 'income') {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCard(income: income, expense: expense),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No transactions yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];

                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + index * 100),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TransactionTile(
                          transaction: tx,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddTransactionScreen(transaction: tx),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Transaction'),
                                content: const Text(
                                    'Are you sure you want to delete this transaction?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await _supabaseService.deleteTransaction(tx.id!);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Transaction deleted"),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );
}
}