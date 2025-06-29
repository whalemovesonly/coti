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
      title: tr('bridge_hack.title'),
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
                    tr('bridge_hack.tip'),
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
      ),
    );
  }
}