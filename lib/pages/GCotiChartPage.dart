import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class GCotiChartPage extends StatefulWidget {
  const GCotiChartPage({super.key});

  @override
  State<GCotiChartPage> createState() => _GCotiChartPageState();
}

class _GCotiChartPageState extends State<GCotiChartPage> {
  final List<int> daysOptions = [3, 7, 21, 30, 90, 365, 1095];
  int selectedDays = 3;
  bool isLoading = false;
  String statusKey = 'gcotichart.fetching_status';
  List<String> statusArgs = [];

  List<String> labels = [];
  List<double> deposits = [];
  List<double> withdrawals = [];

  final List<String> addressesToWatch = [
    '0x5e19f674b3B55dF897C09824a2ddFAD6939e3d1D'.toLowerCase(),
  ];

  final String token = '0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1';
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
      String url = '$baseUrl/$address/token-transfers?token=$token';
      if (params != null) {
        final paramStr = params.entries.map((e) => '${e.key}=${e.value}').join('&');
        url += '&$paramStr';
      }

      final response = await http.get(Uri.parse(url), headers: {'accept': 'application/json'});
      if (response.statusCode != 200) break;

      final data = jsonDecode(response.body);
      final transactions = data['items'] ?? [];
      bool stop = false;

      for (final tx in transactions) {
        final txTime = DateTime.parse(tx['timestamp']);
        if (txTime.isBefore(timeLimit)) {
          stop = true;
          break;
        }
        allTransactions.add(tx);
      }

      if (stop || data['next_page_params'] == null) break;
      params = (data['next_page_params'] as Map)
          .map((key, value) => MapEntry(key.toString(), value.toString()));
    }

    return allTransactions;
  }

  Map<String, Map<String, double>> groupTransactionsByDay(List<dynamic> transactions) {
    final result = <String, Map<String, double>>{};
    for (final tx in transactions) {
      final dateKey = DateTime.parse(tx['timestamp']).toIso8601String().substring(0, 10);
      final value = double.tryParse(tx['total']?['value'] ?? '0') ?? 0.0;
      final isDeposit = addressesToWatch.contains(tx['to']?['hash']?.toLowerCase());
      final isWithdraw = addressesToWatch.contains(tx['from']?['hash']?.toLowerCase());

      result.putIfAbsent(dateKey, () => {'deposits': 0, 'withdrawals': 0});
      if (isDeposit) result[dateKey]!['deposits'] = result[dateKey]!['deposits']! + value / 1e18;
      if (isWithdraw) result[dateKey]!['withdrawals'] = result[dateKey]!['withdrawals']! + value / 1e18;
    }
    return result;
  }

  Future<void> _fetchData() async {
    setState(() {
    isLoading = true;
    statusKey = 'gcotichart.fetching_status';
    statusArgs = [];
    });

    List<dynamic> combined = [];
    for (final address in addressesToWatch) {
      final txs = await fetchTransactionsWithinDays(address, selectedDays);
      combined.addAll(txs);
    }

    final grouped = groupTransactionsByDay(combined);
    final sortedKeys = grouped.keys.toList()..sort();

    setState(() {
    labels = sortedKeys;
    deposits = sortedKeys.map((k) => grouped[k]!['deposits']!).toList();
    withdrawals = sortedKeys.map((k) => grouped[k]!['withdrawals']!).toList();
    if (labels.isNotEmpty) {
        statusKey = 'gcotichart.success_status';
        statusArgs = [labels.first, labels.last];
    } else {
        statusKey = 'gcotichart.empty_status';
        statusArgs = [];
    }
    isLoading = false;
    });
  }

  Widget buildChart() {
    if (labels.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 400,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(labels.length, (index) {
            return BarChartGroupData(x: index, barRods: [
              BarChartRodData(toY: deposits[index], color: Colors.cyanAccent),
              BarChartRodData(toY: withdrawals[index], color: Colors.redAccent),
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
                  final date = labels[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      date.substring(5),
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
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
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
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
      title: tr('gcotichart.chart_title'),
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
                              setState(() => selectedDays = value!);
                              _fetchData();
                            },
                      items: daysOptions.map((day) => DropdownMenuItem<int>(
                        value: day,
                        child: Text('gcotichart.day_option'.tr(args: [day.toString()])),
                      )).toList(),
                    ),
                    IconButton(
                      onPressed: isLoading ? null : _fetchData,
                      icon: Icon(Icons.refresh, color: color.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                statusKey.tr(args: statusArgs),
                style: text.bodyMedium?.copyWith(color: color.tertiary),
                ),
                const SizedBox(height: 10),
                if (labels.isNotEmpty)
                  Text(
                    'gcotichart.result_text'.tr(args: [
  deposits.reduce((a, b) => a + b).toStringAsFixed(4),
  withdrawals.reduce((a, b) => a + b).toStringAsFixed(4),
]),
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                buildChart(),
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
