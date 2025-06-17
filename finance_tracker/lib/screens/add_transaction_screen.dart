import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // For edit mode

  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  String _selectedCategory = 'General';

  final _supabaseService = SupabaseService();

  final Map<String, IconData> _categoryIcons = {
  'General': Icons.category,
  'Food': Icons.restaurant,
  'Transport': Icons.directions_bus,
  'Shopping': Icons.shopping_cart,
  'Salary': Icons.attach_money,
  'Healthcare': Icons.local_hospital,
  'Utilities': Icons.lightbulb,
  'Entertainment': Icons.movie,
  'Education': Icons.school,
  'Travel': Icons.flight,
  'Investment': Icons.trending_up,
  'Gift': Icons.card_giftcard,
  'Insurance': Icons.security,
  'Tax': Icons.receipt_long,
  'Loan': Icons.account_balance,
  'Subscription': Icons.subscriptions,
  'Pets': Icons.pets,
  'Donation': Icons.volunteer_activism,
  'Rent': Icons.home,
  'Other': Icons.more_horiz,
};
late final List<String> _categories;

  @override
  void initState() {
    super.initState();
    print('initState called');
    _categories = _categoryIcons.keys.toList();
    if (widget.transaction != null) {
      print('Editing transaction with ID: ${widget.transaction!.id}');
      // If editing, populate fields with existing transaction
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _selectedCategory = widget.transaction!.category;
      _selectedType = widget.transaction!.type;
    } else {
      print('Adding a new transaction');
    }
  }

  Future<void> _submit() async {
    print('_submit method called');
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text);

      print('Form is valid. Title: $title, Amount: $amount');

      final transactionData = {
        'title': title,
        'amount': amount,
        'date': _selectedDate.toIso8601String(),
        'category': _selectedCategory,
        'type': _selectedType,
      };

      print('Transaction data: $transactionData');

      try {
        if (widget.transaction == null) {
          print('Adding new transaction');
          // Add new transaction
          await _supabaseService.addTransaction(transactionData);
          print('Transaction added successfully');
        } else {
          print('Updating transaction with ID: ${widget.transaction!.id}');
          // Update transaction by its ID from Supabase
          await _supabaseService.updateTransaction(widget.transaction!.id!, transactionData);
          print('Transaction updated successfully');
        }

        print('Navigating back');
        Navigator.pop(context);
      } catch (e) {
        print('Error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      print('Form is not valid');
    }
  }

  Future<void> _pickDate() async {
    print('_pickDate method called');
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      print('Date picked: $picked');
      setState(() {
        _selectedDate = picked;
      });
    } else {
      print('No date picked');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build method called');
    final isEditMode = widget.transaction != null;
    print('Is edit mode: $isEditMode');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
  ),

                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 15),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
  ),

                ),
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Enter valid amount'
                        : null,
              ),
              const SizedBox(height: 15),

              // Date Picker
              InkWell(
                onTap: () {
                  print('Date picker tapped');
                  _pickDate();
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
  ),

                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 15),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                menuMaxHeight: 400,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(),
                  
                ),
                items: _categories.map((cat) {
  return DropdownMenuItem<String>(
    value: cat,
    child: Row(
      children: [
        Icon(_categoryIcons[cat] ?? Icons.category, size: 20),
        const SizedBox(width: 10),
        Text(
          cat,
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
      ],
    ),
  );
}).toList(),

                onChanged: (val) {
                  print('Category selected: $val');
                  setState(() {
                    _selectedCategory = val!;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Transaction Type: Income or Expense
              const Text(
                'Transaction Type',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Income', style: TextStyle(fontSize: 16),),
                      value: 'income',
                      groupValue: _selectedType,
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        print('Transaction type selected: $val');
                        setState(() {
                          _selectedType = val!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Expense', style: TextStyle(fontSize: 16),),
                      value: 'expense',
                      groupValue: _selectedType,
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        print('Transaction type selected: $val');
                        setState(() {
                          _selectedType = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  print('Submit button pressed');
                  _submit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                child: Text(isEditMode ? 'Update Transaction' : 'Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
