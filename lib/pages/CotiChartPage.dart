import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class CotiChartPage extends StatefulWidget {
  const CotiChartPage({super.key});

  @override
  State<CotiChartPage> createState() => _CotiChartPageState();
}

class _CotiChartPageState extends State<CotiChartPage> {
  final List<int> daysOptions = [3, 7, 21, 30, 90, 365, 1095];
  int selectedDays = 3;
  bool isLoading = false;
  String statusKey = 'cotichart.fetching_status';
  List<String> statusArgs = [];

  List<String> labels = [];
  List<double> deposits = [];
  List<double> withdrawals = [];

  final ScrollController _scrollController = ScrollController();

  final List<String> addressesToWatch = [
    '0x5e19f674b3b55df897c09824a2ddfad6939e3d1d',
  ];

  final String token = '0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1';
  final String baseUrl = 'https://mainnet.cotiscan.io/api/v2/addresses';

  Map<String, double> depositorTotals = {};
  Map<String, double> withdrawerTotals = {};

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
        final fromAddress = tx['from']?['hash']?.toString().toLowerCase();

        final types = tx['transaction_types'] as List?;
        String type = '';
        if (types != null && types.isNotEmpty) {
          type = types.first;
        }

        if ((toAddress == address || fromAddress == address) && tx['result'] == 'success' && type == 'coin_transfer') {
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

  Map<String, Map<String, double>> groupTransactionsByDay(List<dynamic> transactions) {
    final result = <String, Map<String, double>>{};
    for (final tx in transactions) {
      final dateKey = DateTime.parse(tx['timestamp']).toIso8601String().substring(0, 10);
      final value = double.tryParse(tx['value'] ?? '0') ?? 0.0;
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
      statusKey = 'cotichart.fetching_status';
      statusArgs = [];
    });

    List<dynamic> combined = [];
    for (final address in addressesToWatch) {
      final txs = await fetchTransactionsWithinDays(address, selectedDays);
      combined.addAll(txs);
    }

    final grouped = groupTransactionsByDay(combined);
    final sortedKeys = grouped.keys.toList()..sort();

    // Process depositors & withdrawers
    depositorTotals = {};
    withdrawerTotals = {};
    for (final tx in combined) {
      final value = double.tryParse(tx['value'] ?? '0') ?? 0.0;
      final amount = value / 1e18;
      final from = tx['from']?['hash']?.toLowerCase();
      final to = tx['to']?['hash']?.toLowerCase();

      for (final treasury in addressesToWatch) {
        if (to == treasury && from != null) {
          depositorTotals[from] = (depositorTotals[from] ?? 0.0) + amount;
        }
        if (from == treasury && to != null) {
          withdrawerTotals[to] = (withdrawerTotals[to] ?? 0.0) + amount;
        }
      }
    }

    setState(() {
      labels = sortedKeys;
      deposits = sortedKeys.map((k) => grouped[k]!['deposits']!).toList();
      withdrawals = sortedKeys.map((k) => grouped[k]!['withdrawals']!).toList();
      if (labels.isNotEmpty) {
        statusKey = 'cotichart.success_status';
        statusArgs = [labels.first, labels.last];
      } else {
        statusKey = 'cotichart.empty_status';
        statusArgs = [];
      }
      isLoading = false;
    });
  }

  Widget buildAddressList(List<MapEntry<String, double>> list, String title, String typeKey, ColorScheme color, TextTheme text) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: text.titleSmall?.copyWith(color: color.primary)),
          const SizedBox(height: 8),
          ...list.asMap().entries.map((entry) {
            final index = entry.key; // ✅ Now this is 0, 1, 2, ...
            final addr = entry.value.key;
            final value = entry.value.value.toStringAsFixed(4);

                      // Determine the leaderboard icon with tooltip
            Widget? leaderboardIcon;
            if (index == 0) {
              leaderboardIcon = Tooltip(
                message: '🥇 Rank #1',
                child: const Text('🥇', style: TextStyle(fontSize: 36)),
              );
            } else if (index == 1) {
              leaderboardIcon = Tooltip(
                message: '🥈 Rank #2',
                child: const Text('🥈', style: TextStyle(fontSize: 34)),
              );
            } else if (index == 2) {
              leaderboardIcon = Tooltip(
                message: '🥉 Rank #3',
                child: const Text('🥉', style: TextStyle(fontSize: 32)),
              );
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addr, style: text.bodySmall?.copyWith(color: color.onSurface)),
                        Text('${tr('cotichart.$typeKey')}: $value', style: text.bodySmall?.copyWith(color: color.primary)),
                      ],
                    ),
                  ),
                  if (leaderboardIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: leaderboardIcon,
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: color.secondary),
                    onPressed: () => Clipboard.setData(ClipboardData(text: addr)),
                    tooltip: 'Copy',
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new, size: 16, color: color.secondary),
                    onPressed: () => launchUrl(Uri.parse('https://mainnet.cotiscan.io/address/$addr')),
                    tooltip: 'Open',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildChart(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    const double leftTitleWidth = 80;
    const double barGroupWidth = 40;
    final double chartContentWidth = labels.length * barGroupWidth.toDouble();

    final maxDeposit = deposits.isNotEmpty ? deposits.reduce((a, b) => a > b ? a : b) : 0;
    final maxWithdrawal = withdrawals.isNotEmpty ? withdrawals.reduce((a, b) => a > b ? a : b) : 0;
    final maxY = (maxDeposit > maxWithdrawal ? maxDeposit : maxWithdrawal) * 1.2;
    final yIntervalCount = 5;
    final yStep = maxY / yIntervalCount;

    return SizedBox(
      height: 400,
      child: Row(
        children: [
          SizedBox(
            width: leftTitleWidth,
            child: Column(
              children: List.generate(yIntervalCount + 1, (i) {
                final value = (yStep * (yIntervalCount - i)).round();
                return Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        value.toString(),
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 8),
                child: SizedBox(
                  width: chartContentWidth < MediaQuery.of(context).size.width
                      ? MediaQuery.of(context).size.width
                      : chartContentWidth,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
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
                              '${isDeposit ? tr('cotichart.deposit') : tr('cotichart.withdrawal')}\n$label\n$value',
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
                          BarChartRodData(toY: deposits[index], color: colorScheme.primary),
                          BarChartRodData(toY: withdrawals[index], color: colorScheme.tertiary),
                        ]);
                      }),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                              if (index % 2 != 0) return const SizedBox.shrink();
                              final date = labels[index];
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(date.substring(5), style: TextStyle(fontSize: 10, color: textColor)),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text = theme.textTheme;

    final topDepositorsList = depositorTotals.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topWithdrawersList = withdrawerTotals.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return MainLayout(
      title: tr('cotichart.chart_title'),
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
                        onChanged: isLoading ? null : (value) {
                          setState(() => selectedDays = value!);
                          _fetchData();
                        },
                        items: daysOptions.map((day) => DropdownMenuItem<int>(
                          value: day,
                          child: Text('cotichart.day_option'.tr(args: [day.toString()])),
                        )).toList(),
                      ),
                      IconButton(
                        onPressed: isLoading ? null : _fetchData,
                        icon: Icon(Icons.refresh, color: color.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(statusKey.tr(args: statusArgs), style: text.bodyMedium?.copyWith(color: color.tertiary)),
                  const SizedBox(height: 10),
                  if (labels.isNotEmpty)
                    SelectableText(
                      tr('cotichart.result_text', args: [
                        deposits.reduce((a, b) => a + b).toStringAsFixed(4),
                        withdrawals.reduce((a, b) => a + b).toStringAsFixed(4),
                      ]),
                      style: text.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  buildChart(context),
                  const SizedBox(height: 30),
                  if (topDepositorsList.isNotEmpty || topWithdrawersList.isNotEmpty)
                    Column(
                      children: [
                        Text(tr('cotichart.address_summary'), style: text.titleMedium?.copyWith(color: color.primary)),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildAddressList(topDepositorsList.take(10).toList(), tr('cotichart.top_depositors'), 'deposits', color, text),
                            const SizedBox(width: 16),
                            buildAddressList(topWithdrawersList.take(10).toList(), tr('cotichart.top_withdrawers'), 'withdrawals', color, text),
                          ],
                        ),
                      ],
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