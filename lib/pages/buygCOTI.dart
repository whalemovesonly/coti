import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class BuyGCOTIPage extends StatelessWidget {
  const BuyGCOTIPage({super.key});

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MainLayout(
      title: tr('buy_gcoti.title'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buyLink(
              context,
              tr('buy_gcoti.mexc'),
              'https://www.mexc.com/exchange/gCOTI_USDT',
            ),
            _buyLink(
              context,
              tr('buy_gcoti.bitrue'),
              'https://www.bitrue.com/trade/gCOTI_USDT',
            ),
            _buyLink(
              context,
              tr('buy_gcoti.carbondefi'),
              'https://coti.carbondefi.xyz/trade/market?base=0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE&quote=0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1',
            ),
            const SizedBox(height: 40),
            const SecurityNote(),
            const SizedBox(height: 20),
            const ContactAndDonate(),
          ],
        ),
      ),
    );
  }

  Widget _buyLink(BuildContext context, String label, String url) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.secondary,
          side: BorderSide(color: colorScheme.secondary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(50),
          textStyle: textTheme.bodyLarge,
        ),
        onPressed: () => _launch(url),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}