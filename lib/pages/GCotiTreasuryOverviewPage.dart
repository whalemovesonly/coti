import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class GCotiTreasuryOverviewPage extends StatefulWidget {
  const GCotiTreasuryOverviewPage({super.key});

  @override
  State<GCotiTreasuryOverviewPage> createState() => _GCotiTreasuryOverviewPageState();
}

class _GCotiTreasuryOverviewPageState extends State<GCotiTreasuryOverviewPage> {
  final TextEditingController _walletController = TextEditingController();
  bool isLoading = false;
  String statusKey = '';
  List<String> statusArgs = [];
  String? resultText;
  List<String> labels = [];
  List<double> deposits = [];
  List<double> withdrawals = [];

  final String treasuryWallet = '0x5e19f674b3B55dF897C09824a2ddFAD6939e3d1D';
  final String token = '0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1';
  final String baseUrl = 'https://mainnet.cotiscan.io/api/v2/addresses';

  Future<List<dynamic>> fetchTransactions(String address) async {
    List<dynamic> allTransactions = [];
    Map<String, String>? params;

    while (true) {
      String url = '$baseUrl/$address/token-transfers?token=$token';
      if (params != null) {
        final paramStr = params.entries.map((e) => '${e.key}=${e.value}').join('&');
        url += '&$paramStr';
      }

      final response = await http.get(Uri.parse(url), headers: {'accept': 'application/json'});
      if (response.statusCode != 200) break;

      final data = jsonDecode(response.body);
      final items = data['items'] ?? [];
      allTransactions.addAll(items);

      if (data['next_page_params'] == null) break;
      params = (data['next_page_params'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    return allTransactions;
  }

  Map<String, Map<String, double>> groupByDate(List<dynamic> txs) {
    final grouped = <String, Map<String, double>>{};
    for (final tx in txs) {
      final ts = tx['timestamp'];
      if (ts == null) continue;
      final dateKey = DateTime.parse(ts).toIso8601String().substring(0, 10);
      final value = double.tryParse(tx['total']?['value'] ?? '0') ?? 0.0;
      final from = tx['from']?['hash']?.toString().toLowerCase();
      final to = tx['to']?['hash']?.toString().toLowerCase();
      grouped.putIfAbsent(dateKey, () => {'deposits': 0, 'withdrawals': 0});
      if (to == treasuryWallet.toLowerCase()) {
        grouped[dateKey]!['deposits'] = grouped[dateKey]!['deposits']! + value / 1e18;
      }
      if (from == treasuryWallet.toLowerCase()) {
        grouped[dateKey]!['withdrawals'] = grouped[dateKey]!['withdrawals']! + value / 1e18;
      }
    }
    return grouped;
  }

  Future<void> _fetchData() async {
    FocusScope.of(context).unfocus();
    final address = _walletController.text.trim();
    final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
    if (!isValid) {
      setState(() {
        statusKey = 'gcotiforwalletoverview.invalid_address';
        resultText = null;
        deposits.clear();
        withdrawals.clear();
        labels.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusKey = 'gcotiforwalletoverview.fetching_status';
      statusArgs = [];
    });

    try {
      final txs = await fetchTransactions(address);
      final grouped = groupByDate(txs);
      final sortedDates = grouped.keys.toList()..sort();

      setState(() {
        labels = sortedDates;
        deposits = sortedDates.map((k) => grouped[k]!['deposits']!).toList();
        withdrawals = sortedDates.map((k) => grouped[k]!['withdrawals']!).toList();
        statusKey = labels.isNotEmpty
            ? 'gcotiforwalletoverview.success_status'
            : 'gcotiforwalletoverview.no_tx_found';
        resultText = labels.isNotEmpty
            ? 'gcotiforwalletoverview.result_text'
                .tr(args: [
                  deposits.reduce((a, b) => a + b).toStringAsFixed(4),
                  withdrawals.reduce((a, b) => a + b).toStringAsFixed(4),
                ])
            : null;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        statusKey = 'gcotiforwalletoverview.error_status';
        resultText = null;
        isLoading = false;
      });
    }
  }

 Widget buildChart(BuildContext context) {
  if (labels.isEmpty) return const SizedBox.shrink();

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

  return SizedBox(
    height: 400,
    child: BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: colorScheme.surfaceVariant,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = labels[group.x.toInt()];
              final isDeposit = rodIndex == 0;
              final value = rod.toY;
              return BarTooltipItem(
                '${isDeposit ? 'Deposit' : 'Withdrawal'}\n$label\n$value',
                TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        barGroups: List.generate(labels.length, (index) {
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(
              toY: deposits[index],
              color: colorScheme.primary, // Deposit bar color from theme
            ),
            BarChartRodData(
              toY: withdrawals[index],
              color: colorScheme.tertiary, // Withdrawal bar color from theme
            ),
          ]);
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                if (index % 2 != 0) return const SizedBox.shrink(); // show every other label
                final date = labels[index];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    date.substring(5), // Show MM-DD
                    style: TextStyle(fontSize: 10, color: textColor),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: textColor),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text = theme.textTheme;

    return MainLayout(
      title: tr('gcotiforwalletoverview.treasury_chart_title'),
      child: Container(
        padding: const EdgeInsets.all(32),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(tr('gcotiforwalletoverview.enter_wallet'),
                    style: text.titleMedium?.copyWith(color: color.primary)),
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
                IconButton(
                  onPressed: isLoading ? null : _fetchData,
                  icon: Icon(Icons.refresh, color: color.primary),
                ),
                const SizedBox(height: 20),
                Text(statusKey.tr(args: statusArgs), style: text.bodyMedium?.copyWith(color: color.tertiary)),
                const SizedBox(height: 10),
                if (resultText != null)
                    SelectableText(
                        tr('gcotiforwalletoverview.result_text', args: [
                        deposits.reduce((a, b) => a + b).toStringAsFixed(4),
                        withdrawals.reduce((a, b) => a + b).toStringAsFixed(4),
                        ]),
                        style: text.bodyLarge,
                        textAlign: TextAlign.center,
                    ),
                const SizedBox(height: 20),
                buildChart(context),
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
