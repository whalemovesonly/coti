import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class CotiTreasuryTrackerPage extends StatefulWidget {
  const CotiTreasuryTrackerPage({super.key});

  @override
  State<CotiTreasuryTrackerPage> createState() => _HtmlCotiConversionPageState();
}

class _HtmlCotiConversionPageState extends State<CotiTreasuryTrackerPage> {
  final List<int> dayOptions = [1, 3, 7, 21, 30, 90, 365, 1095];
  int selectedDays = 1;
  bool isLoading = false;

  final TextEditingController _walletController = TextEditingController();
  String statusKey = '';
  double? result;

  final String treasuryWallet = '0x5e19f674b3B55dF897C09824a2ddFAD6939e3d1D';
  final String baseUrl = 'https://mainnet.cotiscan.io/api/v2/addresses';

  Future<List<dynamic>> fetchTransactionsWithinDays(String address, int daysBack) async {
    List<dynamic> allTransactions = [];
    final now = DateTime.now();
    final timeLimit = now.subtract(Duration(days: daysBack));
    Map<String, String>? params;

    while (true) {
      String url = '$baseUrl/$address/transactions';
      if (params != null) {
        final paramStr = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
        url += '?$paramStr';
      }

      final response = await http.get(Uri.parse(url), headers: {'accept': 'application/json'});
      if (response.statusCode != 200) {
        setState(() => statusKey = 'cotiforwallet.error_status');
        break;
      }

      final data = jsonDecode(response.body);
      final transactions = data['items'] ?? [];
      bool stop = false;

      for (final tx in transactions) {
        final to = tx['to']?['hash']?.toString().toLowerCase();
        if (to == treasuryWallet.toLowerCase()) {
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
    final address = _walletController.text.trim();

    if (address.isEmpty || !RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) {
      setState(() {
        statusKey = 'cotiforwallet.invalid_address';
      
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusKey = 'cotiforwallet.fetching_status';
      result = null;
    });

    try {
      final txs = await fetchTransactionsWithinDays(address, selectedDays);
      final totalRaw = sumTransactionValues(txs);
      final total = totalRaw / 1e18;

      setState(() {
        statusKey = txs.isEmpty
            ? 'cotiforwallet.no_tx_found'
            : 'cotiforwallet.success_status';
        result = txs.isEmpty ? null : total;
      });
    } catch (e) {
      setState(() => statusKey = 'cotiforwallet.error_status');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text = theme.textTheme;

    return MainLayout(
      title: 'cotiforwallet.treasury_tracker_title'.tr(),
      child: Container(
        padding: const EdgeInsets.all(32),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('cotiforwallet.enter_wallet'.tr(), style: text.titleMedium?.copyWith(color: color.primary)),
                const SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: TextField(
                    controller: _walletController,
                    onSubmitted: (_) => _fetchData(),
                    enabled: !isLoading,
                    style: text.bodyMedium?.copyWith(color: color.primary),
                    decoration: InputDecoration(
                      hintText: '0x...',
                      hintStyle: TextStyle(color: color.tertiary),
                      filled: true,
                      fillColor: color.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: selectedDays,
                      dropdownColor: color.surface,
                      style: text.bodyMedium?.copyWith(color: color.primary),
                      onChanged: isLoading
                        ? null
                        : (val) {
                            setState(() {
                            selectedDays = val!;
                            });
                            _fetchData(); // ✅ Trigger fetch
                        },
                      items: dayOptions
                          .map((d) => DropdownMenuItem(value: d, child: Text('cotiforwallet.day_option'.tr(args: [d.toString()]))))
                          .toList(),
                    ),
                    IconButton(
                      onPressed: isLoading ? null : _fetchData,
                      icon: Icon(Icons.refresh, color: color.primary),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Text(statusKey.tr(), style: text.bodyMedium?.copyWith(color: color.tertiary), textAlign: TextAlign.center),
                if (result != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'cotiforwallet.result_text'.tr(args: [result!.toStringAsFixed(6), selectedDays.toString()]),
                      style: text.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
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
