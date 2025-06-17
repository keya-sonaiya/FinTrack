import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';


class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  transaction.type == 'income' ? Colors.green : Colors.red,
              child: Icon(
                transaction.type == 'income'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: transaction.category,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      const TextSpan(
        text: ' • ',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
      TextSpan(
        text: DateFormat('dd MMM yyyy').format(transaction.date),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
  overflow: TextOverflow.ellipsis,
),

                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit?.call();
                          } else if (value == 'delete') {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(Icons.edit, color: Colors.blue, size: 18),
                                SizedBox(width: 8),
                                Text("Edit"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text("Delete"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.title,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${transaction.type == 'income' ? '+' : '-'} ₹${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: transaction.type == 'income'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
