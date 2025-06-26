import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
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
  List<FlSpot> depositSpots = [];
  List<FlSpot> withdrawalSpots = [];
  List<String> xLabels = [];

  double totalDeposits = 0;
  double totalWithdrawals = 0;

  final String treasuryWallet = '0x5e19f674b3B55dF897C09824a2ddFAD6939e3d1D';
  final String token = '0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1';
  final String baseUrl = 'https://mainnet.cotiscan.io/api/v2/addresses';

  Future<List<dynamic>> fetchAllTransactions(String address) async {
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
      params = (data['next_page_params'] as Map)
          .map((key, value) => MapEntry(key.toString(), value.toString()));
    }

    return allTransactions;
  }

  Future<void> _fetchData() async {
    FocusScope.of(context).unfocus();
    final address = _walletController.text.trim();

    final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
    if (!isValid) {
      setState(() {
        statusKey = 'gcotiforwalletoverview.invalid_address';
        depositSpots.clear();
        withdrawalSpots.clear();
        xLabels.clear();
        totalDeposits = 0;
        totalWithdrawals = 0;
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusKey = 'gcotiforwalletoverview.fetching_status';
    });

    try {
      final txs = await fetchAllTransactions(address);
      final deposits = <double>[];
      final withdrawals = <double>[];
      final labels = <String>[];

      totalDeposits = 0;
      totalWithdrawals = 0;

      final sorted = txs.where((tx) => tx['timestamp'] != null).toList()
        ..sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));

      for (int i = 0; i < sorted.length; i++) {
        final tx = sorted[i];
        final val = int.tryParse(tx['total']?['value'] ?? '0') ?? 0;
        final value = val / 1e18;
        final date = DateTime.parse(tx['timestamp']);
        final label = '${date.month}/${date.day}';
        labels.add(label);

        final to = tx['to']?['hash']?.toString().toLowerCase();
        final from = tx['from']?['hash']?.toString().toLowerCase();

        if (to == treasuryWallet.toLowerCase()) {
          deposits.add(value);
          withdrawals.add(0);
          totalDeposits += value;
        } else if (from == treasuryWallet.toLowerCase()) {
          withdrawals.add(value);
          deposits.add(0);
          totalWithdrawals += value;
        } else {
          deposits.add(0);
          withdrawals.add(0);
        }
      }

      depositSpots = List.generate(deposits.length, (i) => FlSpot(i.toDouble(), deposits[i]));
      withdrawalSpots = List.generate(withdrawals.length, (i) => FlSpot(i.toDouble(), withdrawals[i]));
      xLabels = labels;

      setState(() {
        statusKey = 'gcotiforwalletoverview.success_status';
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        statusKey = 'gcotiforwalletoverview.error_status';
        isLoading = false;
      });
    }
  }

  Widget _buildChart() {
  if (depositSpots.isEmpty && withdrawalSpots.isEmpty) return const SizedBox.shrink();

  return SizedBox(
    height: 400,
    child: LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: depositSpots,
            isCurved: true,
            color: Colors.greenAccent,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: withdrawalSpots,
            isCurved: true,
            color: Colors.redAccent,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    index < xLabels.length ? xLabels[index] : '',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80, // ✅ Enough space for 10-digit numbers like 1,000,000,000
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
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

    final translatedResult = (depositSpots.isNotEmpty || withdrawalSpots.isNotEmpty)
        ? tr(
            'gcotiforwalletoverview.result_text',
            args: [
              totalDeposits.toStringAsFixed(6),
              totalWithdrawals.toStringAsFixed(6),
            ],
          )
        : null;

    return MainLayout(
      title: 'gcotiforwalletoverview.treasury_chart_title'.tr(),
      child: Container(
        padding: const EdgeInsets.all(32),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('gcotiforwalletoverview.enter_wallet'.tr(), style: text.titleMedium?.copyWith(color: color.primary)),
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
                Text(statusKey.tr(), style: text.bodyMedium?.copyWith(color: color.tertiary)),
                const SizedBox(height: 10),
                if (translatedResult != null)
                  Text(translatedResult, style: text.bodyLarge, textAlign: TextAlign.center),
                const SizedBox(height: 30),
                _buildChart(),
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