import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qarazdare/screens/add_loan_paid.dart';
import 'package:qarazdare/providers/notifier.dart';
import 'package:qarazdare/providers/transaction_notifier.dart';
import 'dart:io'; // ADD THIS

class Person extends ConsumerStatefulWidget {
  final int id;
  const Person({super.key, required this.id});
  @override
  ConsumerState<Person> createState() => _Person();
}

class _Person extends ConsumerState<Person> {
  @override
  Widget build(BuildContext context) {
    final onePerson = ref.watch(serviceProvider);
    final transData = ref.watch(transactionProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(transactionProvider.notifier)
          .getTransPerson(onePerson[widget.id].id);
    });
    final loan = ref.read(transactionProvider.notifier).getTotalLoan();

    // Get the person object
    final person = onePerson[widget.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          person.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 67, 255, 77),
                Color.fromARGB(255, 8, 220, 15),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 5, 249, 13),
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AddLoanPaid(
              personId: person.id,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            // UPDATED CircleAvatar with image support
            CircleAvatar(
              radius: 60, // Made it bigger for better visibility
              backgroundColor: Colors.blue.shade100,
              backgroundImage: person.imagePath != null
                  ? FileImage(File(person.imagePath!)) as ImageProvider?
                  : null,
              child: person.imagePath == null
                  ? Text(
                      person.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(
              height: 15,
            ),
            // Loan amount container
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 119, 220, 127),
                    Color.fromARGB(255, 54, 255, 60),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(255, 165, 0, 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  loan.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Table(
              columnWidths: {
                0: const FlexColumnWidth(2),
                1: const FlexColumnWidth(1.5),
                2: const FlexColumnWidth(1.5),
                3: const FlexColumnWidth(1.5),
              },
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      child: Text(
                        'Loan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      child: Text(
                        'Paid',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      child: Text(
                        'Leftover Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                // Data Rows from transData
                ...transData.reversed.map((transaction) {
                  final remaining = transaction.loan - transaction.paid;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Text(
                          '${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Text(
                          '\$${transaction.loan}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Text(
                          '\$${transaction.paid}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Text(
                          remaining.toString(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: remaining > 0 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
