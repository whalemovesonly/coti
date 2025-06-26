import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class BridgeHackPage extends StatelessWidget {
  const BridgeHackPage({super.key});

  void _launchGitHub() async {
    const url = 'https://github.com/whalemovesonly/coti';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _goHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text = theme.textTheme;

    return MainLayout(
      title: tr('buy_gcoti.title'),
      child: Container(
        padding: const EdgeInsets.all(32),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: color.surface,
                    border: Border.all(color: color.secondary, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'One tip for you: if you want to bridge more than 25K \$COTI from Layer 2 to Ethereum in one day, '
                    'use multiple wallets. Each wallet can bridge up to 25K \$COTI. For example, if you want to bridge '
                    '100K \$COTI, split it into four wallets with 25K each, then start bridging from each wallet to Ethereum. '
                    'It worked for me — and yes, it should work for you too.',
                    style: text.bodyLarge?.copyWith(height: 1.6),
                    textAlign: TextAlign.left,
                  ),
                ),
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