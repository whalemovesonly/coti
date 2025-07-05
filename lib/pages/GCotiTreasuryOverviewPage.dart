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

  final ScrollController _scrollController = ScrollController();

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
      if (response.statusCode != 200) {
        throw Exception('gcotiforwalletoverview.error_status'.tr(args: [response.statusCode.toString()]));
      }

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


Map<String, Map<String, double>> groupByNDays(
  Map<String, Map<String, double>> originalGrouped,
  int interval,
) {
  final entries = originalGrouped.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key)); // sort by date

  final grouped = <String, Map<String, double>>{};
  for (int i = 0; i < entries.length; i += interval) {
    final chunk = entries.sublist(i, (i + interval).clamp(0, entries.length));
    final depositsSum = chunk.fold(0.0, (sum, e) => sum + (e.value['deposits'] ?? 0.0));
    final withdrawalsSum = chunk.fold(0.0, (sum, e) => sum + (e.value['withdrawals'] ?? 0.0));

    final startDate = DateTime.parse(chunk.first.key);
    final endDate = DateTime.parse(chunk.last.key);
    final groupKey = _formatGroupKey(startDate, endDate, interval);

    grouped[groupKey] = {
      'deposits': depositsSum,
      'withdrawals': withdrawalsSum,
    };
  }

  return grouped;
}

String _formatGroupKey(DateTime start, DateTime end, int interval) {
  final formatter = DateFormat('yyyy-MM-dd');
  if (interval == 1 || start.isAtSameMomentAs(end)) {
    return formatter.format(start);
  } else {
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
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
      statusKey = 'gcotiforwalletoverview.fetching_status';
      statusArgs = [];
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


    final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
    if (!isValid) {
      setState(() {
        statusKey = 'gcotiforwalletoverview.invalid_address';
        resultText = null;
        deposits.clear();
        withdrawals.clear();
        labels.clear();
        isLoading = false;
        statusArgs = [];
      });
      return;
    }

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

String formatDateRange(String range) {
  if (!range.contains(' - ')) {
    try {
      final singleDate = DateTime.parse(range);
      return '${singleDate.month}-${singleDate.day}';
    } catch (_) {
      return range;
    }
  }

  final parts = range.split(' - ');
  try {
    final startDate = DateTime.parse(parts[0]);
    final endDate = DateTime.parse(parts[1]);

    final startFormatted = '${startDate.month}-${startDate.day}';
    final endFormatted = '${endDate.month}-${endDate.day}';

    return startFormatted == endFormatted
        ? startFormatted
        : '$startFormatted - $endFormatted';
  } catch (_) {
    return range;
  }
}

double calculateYAxisInterval(double maxY) {
  if (maxY <= 10) return 2;
  if (maxY <= 50) return 10;
  if (maxY <= 100) return 20;
  if (maxY <= 500) return 50;
  if (maxY <= 1000) return 100;
  return (maxY / 10).ceilToDouble();
}

Widget buildChart(BuildContext context) {
  if (labels.isEmpty) return const SizedBox.shrink();


  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      // Or use animateTo for smooth scroll:
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: Duration(milliseconds: 500),
      //   curve: Curves.easeOut,
      // );
    }
  });

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

  const double leftTitleWidth = 80;
  const double barGroupWidth = 40;
  final double chartContentWidth = labels.length * barGroupWidth.toDouble();

  // Get max value
  final maxDeposit = deposits.isNotEmpty ? deposits.reduce((a, b) => a > b ? a : b) : 0;
  final maxWithdrawal = withdrawals.isNotEmpty ? withdrawals.reduce((a, b) => a > b ? a : b) : 0;
  final maxY = (maxDeposit > maxWithdrawal ? maxDeposit : maxWithdrawal) * 1.2;
  final yIntervalCount = 5;
  final yStep = maxY / yIntervalCount;

  return SizedBox(
    height: 400,
    child: Row(
      children: [
        // Fixed Y-axis labels
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
        // Scrollable chart with padding
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController, // 🔁 attach controller here
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 8), // 💡 padding for tooltip
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
                            '${isDeposit ? tr('gcotiforwalletoverview.deposit') : tr('gcotiforwalletoverview.withdrawal')}\n$label\n$value',
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
                          color: colorScheme.primary,
                        ),
                        BarChartRodData(
                          toY: withdrawals[index],
                          color: colorScheme.tertiary,
                        ),
                      ]);
                    }),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
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
                              child: Text(
                                date.substring(5),
                                style: TextStyle(fontSize: 10, color: textColor),
                              ),
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

    return MainLayout(
      title: tr('gcotiforwalletoverview.treasury_chart_title'),
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
      ),
    );
  }
}
