import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../layouts/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class AddCOTINetworkToMetaMask extends StatefulWidget {
  const AddCOTINetworkToMetaMask({super.key});

  @override
  State<AddCOTINetworkToMetaMask> createState() => _AddCOTINetworkToMetaMaskState();
}

class _AddCOTINetworkToMetaMaskState extends State<AddCOTINetworkToMetaMask> {
  int currentStep = 0;

  List<Map<String, String>> get steps => [
        {
          'title': tr('add_coti.step1.title'),
          'text': tr('add_coti.step1.text'),
        },
        {
          'title': tr('add_coti.step2.title'),
          'text': tr('add_coti.step2.text'),
        },
        {
          'title': tr('add_coti.step3.title'),
          'text': tr('add_coti.step3.text'),
        },
        {
          'title': tr('add_coti.step4.title'),
          'text': tr('add_coti.step4.text'),
        },
      ];

  void goToNext() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('add_coti.complete'))),
        );
      }
    });
  }

  void goToPrevious() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/whalemovesonly/coti');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch GitHub link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = steps[currentStep];
    final theme = Theme.of(context);
    context.locale;

    return MainLayout(
      title: tr('add_coti.title'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(color: theme.colorScheme.secondary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    current['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    current['text']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentStep > 0 ? goToPrevious : null,
                  child: Text(tr('add_coti.back')),
                ),
                ElevatedButton(
                  onPressed: goToNext,
                  child: Text(
                    currentStep == steps.length - 1
                        ? tr('add_coti.finish')
                        : tr('add_coti.next'),
                  ),
                ),
              ],
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
}