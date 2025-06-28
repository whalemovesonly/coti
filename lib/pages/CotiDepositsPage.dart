import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class CotiDepositsPage extends StatefulWidget {
  const CotiDepositsPage({super.key});

  @override
  State<CotiDepositsPage> createState() => _CotiDepositsPageState();
}

class _CotiDepositsPageState extends State<CotiDepositsPage> {
  final List<int> daysOptions = [1, 3, 7, 21, 30, 90, 365, 1095];
  int selectedDays = 1;
  bool isLoading = false;

  String statusKey = 'coti.loading_status';
  double? resultValue;

  final List<String> addressesToWatch = [
    '0x5e19f674b3B55dF897C09824a2ddFAD6939e3d1D'.toLowerCase(),
  ];

  final String baseUrl = 'https://mainnet.cotiscan.io/api/v2/addresses';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<List<dynamic>> fetchTransactionsWithinDays(String address, int daysBack) async {
    List<dynamic> allTransactions = [];
    final now = DateTime.now();
    final timeLimit = now.subtract(Duration(days: daysBack));
    Map<String, String>? params;

    while (true) {
      String url = '$baseUrl/$address/transactions';
      if (params != null) {
        final allowedKeys = ['block_number', 'fee', 'hash', 'index'];
        final paramStr = params.entries
            .where((e) => allowedKeys.contains(e.key))
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$paramStr';
      }
      final response = await http.get(Uri.parse(url), headers: {'accept': 'application/json'});

      if (response.statusCode != 200) {
        throw Exception('coti.error_status'.tr(args: [response.statusCode.toString()]));
      }

      final data = jsonDecode(response.body);
      final transactions = data['items'] ?? [];
      bool stop = false;
      

      for (final tx in transactions) {
        final toAddress = tx['to']?['hash']?.toString().toLowerCase();
        
        final types = tx['transaction_types'] as List?;
        String type = '';
        if (types != null && types.isNotEmpty) {
          type = types.first;
        }

        if (toAddress == address && tx['result'] == 'success' && type == 'coin_transfer') {
          final txTime = DateTime.parse(tx['timestamp']);
          if (txTime.isBefore(timeLimit)) {
            stop = true;
            break;
          }
          allTransactions.add(tx);
        }
      }
      if (stop || data['next_page_params'] == null) break;
      params = (data['next_page_params'] as Map)
          .map((key, value) => MapEntry(key.toString(), value.toString()));
      
    }

    return allTransactions;
  }

  int sumTransactionValues(List<dynamic> transactions) {
    int total = 0;
    for (final tx in transactions) {
      try {
        total += int.parse(tx['value'] ?? '0');
      } catch (_) {}
    }
    return total;
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      statusKey = 'coti.fetching_status';
      resultValue = null;
    });

    try {
      List<dynamic> combined = [];
      for (final address in addressesToWatch) {
        final txs = await fetchTransactionsWithinDays(address, selectedDays);
        combined.addAll(txs);
      }
      final totalValueRaw = sumTransactionValues(combined);
      final totalValue = totalValueRaw / 1e18;

      setState(() {
        statusKey = 'coti.success_status';
        resultValue = totalValue;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        statusKey = 'coti.error_status';
        resultValue = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text = theme.textTheme;

    return MainLayout(
      title: 'coti.page_title'.tr(),
      child: Container(
        padding: const EdgeInsets.all(32),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: selectedDays,
                      dropdownColor: color.surface,
                      style: text.bodyMedium?.copyWith(color: color.primary),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                selectedDays = value!;
                              });
                              _fetchData();
                            },
                      items: daysOptions
                          .map((day) => DropdownMenuItem<int>(
                                value: day,
                                child: Text('coti.day_option'.tr(args: [day.toString()])),
                              ))
                          .toList(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: isLoading ? null : _fetchData,
                      icon: Icon(Icons.refresh, color: color.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  statusKey.tr(args: statusKey == 'coti.error_status' ? [''] : []),
                  style: text.bodyMedium?.copyWith(color: color.tertiary),
                ),
                const SizedBox(height: 10),
                if (resultValue != null)
                  Text(
                    'coti.result_text'.tr(args: [
                      resultValue!.toStringAsFixed(6),
                      selectedDays.toString()
                    ]),
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 30),
                const SecurityNote(),
                const SizedBox(height: 20),
                const ContactAndDonate(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}