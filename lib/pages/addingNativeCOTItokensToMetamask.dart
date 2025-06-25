import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../layouts/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class AddCOTITokenToMetaMask extends StatefulWidget {
  const AddCOTITokenToMetaMask({super.key});

  @override
  State<AddCOTITokenToMetaMask> createState() => _AddCOTITokenToMetaMaskState();
}

class _AddCOTITokenToMetaMaskState extends State<AddCOTITokenToMetaMask> {
  int currentStep = 0;

  final List<Map<String, String>> steps = [
    {
      'title': tr('add_token.step1.title'),
      'text': tr('add_token.step1.text'),
      'link': 'https://mainnet.cotiscan.io/tokens'
    },
    {
      'title': tr('add_token.step2.title'),
      'text': tr('add_token.step2.text')
    },
    {
      'title': tr('add_token.step3.title'),
      'text': tr('add_token.step3.text')
    },
    {
      'title': tr('add_token.step4.title'),
      'text': tr('add_token.step4.text')
    },
    {
      'title': tr('add_token.step5.title'),
      'text': tr('add_token.step5.text')
    },
    {
      'title': tr('add_token.step6.title'),
      'text': tr('add_token.step6.text')
    },
    {
      'title': tr('add_token.step7.title'),
      'text': tr('add_token.step7.text')
    },
    {
      'title': tr('add_token.step8.title'),
      'text': tr('add_token.step8.text')
    },
    {
      'title': tr('add_token.step9.title'),
      'text': tr('add_token.step9.text')
    },
  ];

  void goToNext() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('add_token.tutorial_complete'))),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MainLayout(
      title: tr('add_token.title'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              tr('add_token.heading'),
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.secondary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    step['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: step['link'] != null
                        ? () => _launchUrl(step['link']!)
                        : null,
                    child: Text(
                      step['text']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: step['link'] != null
                            ? colorScheme.secondary.withOpacity(0.9)
                            : textTheme.bodyMedium?.color,
                        decoration: step['link'] != null ? TextDecoration.underline : null,
                      ),
                      textAlign: TextAlign.left,
                    ),
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
                  child: Text(tr('add_token.back')),
                ),
                ElevatedButton(
                  onPressed: goToNext,
                  child: Text(currentStep == steps.length - 1 ? tr('add_token.finish') : tr('add_token.next')),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: colorScheme.tertiary, width: 6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('add_token.note_title'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('add_token.note_intro'),
                    style: TextStyle(color: colorScheme.tertiary),
                  ),
                  const SizedBox(height: 10),
                  Text(tr('add_token.note_1'), style: TextStyle(color: colorScheme.tertiary)),
                  Text(tr('add_token.note_2'), style: TextStyle(color: colorScheme.tertiary)),
                  Text(tr('add_token.note_3'), style: TextStyle(color: colorScheme.tertiary)),
                  Text(tr('add_token.note_4'), style: TextStyle(color: colorScheme.tertiary)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _launchUrl('https://github.com/whalemovesonly/coti'),
                    child: Text(
                      tr('add_token.note_closing'),
                      style: TextStyle(
                        color: colorScheme.tertiary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
