import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';

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

    return MainLayout(
      title: 'Buy \$gCOTI',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('🏠 Home'),
            ),
            const SizedBox(height: 24),
            Text(
              'Where to buy \$gCOTI:',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buyLink(
              context,
              'Buy \$gCOTI on MEXC',
              'https://www.mexc.com/exchange/gCOTI_USDT',
            ),
            _buyLink(
              context,
              'Buy \$gCOTI on Bitrue',
              'https://www.bitrue.com/trade/gCOTI_USDT',
            ),
            _buyLink(
              context,
              'Buy \$gCOTI on CarbonDeFi',
              'https://coti.carbondefi.xyz/trade/market?base=0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE&quote=0x7637C7838EC4Ec6b85080F28A678F8E234bB83D1',
            ),
            const SizedBox(height: 40),
            const SecurityNote(),
          ],
        ),
      ),
    );
  }

  Widget _buyLink(BuildContext context, String label, String url) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: const Color(0xFF1f2833),
          foregroundColor: const Color(0xFF66fcf1),
          side: const BorderSide(color: Color(0xFF66fcf1)),
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: () => _launch(url),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
