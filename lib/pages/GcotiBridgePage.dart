import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class GcotiBridgePage extends StatefulWidget {
  const GcotiBridgePage({super.key});

  @override
  State<GcotiBridgePage> createState() => _GcotiBridgePageState();
}

class _GcotiBridgePageState extends State<GcotiBridgePage> {
  final List<int> daysOptions = [1, 3, 7, 21, 30, 90, 365, 1095];
  int selectedDays = 1;
  bool isLoading = false;

  String statusMessage = tr('gcoti_bridge.status.loading');
  double? resultValue;

  final List<String> addressesToWatch = [
    '0x61BF10A1a27B2d99De0a59a06200A62ED579D685'.toLowerCase(),
  ];

  final String baseUrl = 'https://mainnet.cotiscan.io/api/v2/addresses';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<List<dynamic>> fetchTokenTransfersWithinDays(String address, int daysBack) async {
    List<dynamic> allTransfers = [];
    final now = DateTime.now();
    final timeLimit = now.subtract(Duration(days: daysBack));
    Map<String, String>? params;

    while (true) {
      String url = '$baseUrl/$address/token-transfers?token=0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1';
      if (params != null) {
        final paramStr = params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '&$paramStr';
      }

      final response = await http.get(Uri.parse(url), headers: {'accept': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception('Error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final transfers = data['items'] ?? [];
      bool stop = false;

      for (final tx in transfers) {
        final fromAddress = tx['from']?['hash']?.toString().toLowerCase();
        final timestamp = tx['timestamp'];
        if (fromAddress == address && timestamp != null) {
          final txTime = DateTime.tryParse(timestamp);
          if (txTime != null && txTime.isBefore(timeLimit)) {
            stop = true;
            break;
          }
          allTransfers.add(tx);
        }
      }

      if (stop || data['next_page_params'] == null) break;
      params = (data['next_page_params'] as Map)
          .map((key, value) => MapEntry(key.toString(), value.toString()));
    }

    return allTransfers;
  }

  int sumTransferValues(List<dynamic> transfers) {
    int total = 0;
    for (final tx in transfers) {
      try {
        total += int.parse(tx['total']?['value'] ?? '0');
      } catch (_) {}
    }
    return total;
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      statusMessage = tr('gcoti_bridge.status.fetching');
      resultValue = null;
    });

    try {
      List<dynamic> combined = [];
      for (final address in addressesToWatch) {
        final txs = await fetchTokenTransfersWithinDays(address, selectedDays);
        combined.addAll(txs);
      }
      final totalValueRaw = sumTransferValues(combined);
      final totalValue = totalValueRaw / 1e18;

      setState(() {
        statusMessage = tr('gcoti_bridge.status.success');
        resultValue = totalValue;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        statusMessage = tr('gcoti_bridge.status.error');
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
      title: tr('gcoti_bridge.title'),
      child: Container(
        padding: const EdgeInsets.all(0),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                                  child: Text(tr('gcoti_bridge.dropdown_label', namedArgs: {
                                    'days': day.toString()
                                  })),
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
                    statusMessage,
                    style: text.bodyMedium?.copyWith(color: color.tertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (resultValue != null)
                    Text(
                      tr('gcoti_bridge.result', namedArgs: {
                        'amount': resultValue!.toStringAsFixed(6),
                        'days': selectedDays.toString(),
                      }),
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