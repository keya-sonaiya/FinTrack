  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../models/transaction_model.dart';

  final supabase = Supabase.instance.client;

  class SupabaseService {
    /// Add a new transaction for the logged-in user
    Future<void> addTransaction(Map<String, dynamic> transactionData) async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not signed in");

      try {
        await supabase.from('transactions').insert({
          ...transactionData,
          'user_id': user.id,
        });
      } catch (e) {
        throw Exception("Failed to insert transaction: $e");
      }
    }

    /// Get all transactions of the logged-in user, sorted by latest date
    Future<List<TransactionModel>> getTransactions() async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not signed in");

      try {
        final data = await supabase
            .from('transactions')
            .select()
            .eq('user_id', user.id)
            .order('date', ascending: false);

        return (data as List<dynamic>)
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception("Failed to fetch transactions: $e");
      }
    }

    /// Update an existing transaction
    Future<void> updateTransaction(String id, Map<String, dynamic> updatedData) async {
      try {
        await supabase
            .from('transactions')
            .update(updatedData)
            .eq('id', id);
      } catch (e) {
        throw Exception("Failed to update transaction: $e");
      }
    }

    /// Delete a transaction by ID
    Future<void> deleteTransaction(String id) async {
      try {
        await supabase
            .from('transactions')
            .delete()
            .eq('id', id);
      } catch (e) {
        throw Exception("Failed to delete transaction: $e");
      }
    }

    /// Get current user
    User? getCurrentUser() {
      return supabase.auth.currentUser;
    }

    /// Sign out user
    Future<void> signOut() async {
      try {
        await supabase.auth.signOut();
      } catch (e) {
        throw Exception("Failed to sign out: $e");
      }
    }

    Future<Map<String, dynamic>?> getUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  }