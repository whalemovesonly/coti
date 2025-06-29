import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class GCotiTreasuryTrackerPage extends StatefulWidget {
  const GCotiTreasuryTrackerPage({super.key});

  @override
  State<GCotiTreasuryTrackerPage> createState() => _GCotiTreasuryTrackerPageState();
}

class _GCotiTreasuryTrackerPageState extends State<GCotiTreasuryTrackerPage> {
  final List<int> daysOptions = [1, 3, 7, 21, 30, 90, 365, 1095];
  int selectedDays = 1;
  bool isLoading = false;

  final TextEditingController _walletController = TextEditingController();
  String statusKey = '';
  double? resultValue;
  String? currentAddress;

  final String treasuryWallet = '0x5e19f674b3B55dF897C09824a2ddFAD6939e3d1D';
  final String token = '0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1';
  final String baseUrl = 'https://mainnet.cotiscan.io/api/v2/addresses';

  Future<List<dynamic>> fetchTransactionsWithinDays(String address, int daysBack) async {
    List<dynamic> allTransactions = [];
    final now = DateTime.now();
    final timeLimit = now.subtract(Duration(days: daysBack));
    Map<String, String>? params;

    while (true) {
      String url = '$baseUrl/$address/token-transfers?token=$token';
      if (params != null) {
        final paramStr = params.entries.map((e) => '${e.key}=${e.value}').join('&');
        url += '&$paramStr';
      }

      final response = await http.get(Uri.parse(url), headers: {'accept': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception('gcotiforwallet.error_status'.tr(args: [response.statusCode.toString()]));
      }

      final data = jsonDecode(response.body);
      final transactions = data['items'] ?? [];
      bool stop = false;

      for (final tx in transactions) {
        final toAddress = tx['to']?['hash']?.toString().toLowerCase();
        if (toAddress == treasuryWallet.toLowerCase()) {
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
        total += int.parse(tx['total']['value'] ?? '0');
      } catch (_) {}
    }
    return total;
  }

Future<String?> fetchZnsAddress(String domainInput) async {

    if (domainInput.isEmpty || RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(domainInput)) {
      return null;
    }

  final cleanedDomain = domainInput.toLowerCase().endsWith('.coti')
      ? domainInput.substring(0, domainInput.length - 5)
      : domainInput;
  final proxyUrl = Uri.parse(
    'https://zns.bio/api/resolveDomain?chain=2632500&domain=$cleanedDomain',
  );

  try {
    final response = await http.get(proxyUrl);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('address')) {
        return data['address'];
      }
    } else {
      print('Failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
  
  return null;
}

  Future<void> _fetchData() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      statusKey = 'gcotiforwallet.fetching_status';
      resultValue = null;
    });

    final address1 = _walletController.text.trim();
    final address2 = await fetchZnsAddress(address1); // or 'example.coti'
    String address = "";
    if (address2 != null)
    {
        address = address2;
    }else
    {
       address = _walletController.text.trim();
    }
    print('address: $address');
    if (address.isEmpty || !RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) {
      setState(() {
        statusKey = 'gcotiforwallet.invalid_address';
        resultValue = null;
        isLoading = false;
      });
      return;
    }

    setState(() {
      currentAddress = address;
    });

    try {
      final txs = await fetchTransactionsWithinDays(address, selectedDays);
      final totalValueRaw = sumTransactionValues(txs);
      final totalValue = totalValueRaw / 1e18;

      setState(() {
        statusKey = txs.isEmpty ? 'gcotiforwallet.no_tx_found' : 'gcotiforwallet.success_status';
        resultValue = txs.isEmpty ? null : totalValue;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        statusKey = 'gcotiforwallet.error_status';
        resultValue = null;
        isLoading = false;
      });
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
      title: 'gcotiforwallet.treasury_tracker_title'.tr(),
      child: Container(
        padding: const EdgeInsets.all(0),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: 
            Padding(
             padding: const EdgeInsets.all(16.0), // applies to top, bottom, left, right
             child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'gcotiforwallet.enter_wallet'.tr(),
                  style: text.titleMedium?.copyWith(color: color.primary),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: TextField(
                    controller: _walletController,
                    onSubmitted: (_) => _fetchData(),
                    enabled: !isLoading,
                    style: text.bodyMedium?.copyWith(color: color.primary),
                    decoration: InputDecoration(
                      hintText: '0x... || .coti',
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
                          : (value) {
                              setState(() {
                                selectedDays = value!;
                              });
                              _fetchData();
                            },
                      items: daysOptions
                          .map((day) => DropdownMenuItem<int>(
                                value: day,
                                child: Text('gcotiforwallet.day_option'.tr(args: [day.toString()])),
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
                  statusKey.tr(args: resultValue != null ? [] : []),
                  style: text.bodyMedium?.copyWith(color: color.tertiary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (resultValue != null)
                  Text(
                    'gcotiforwallet.result_text'.tr(args: [
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
      ),
    );
  }
}