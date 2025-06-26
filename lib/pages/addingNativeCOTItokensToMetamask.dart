import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../layouts/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class AddCOTITokenToMetaMask extends StatefulWidget {
  const AddCOTITokenToMetaMask({super.key});

  @override
  State<AddCOTITokenToMetaMask> createState() => _AddCOTITokenToMetaMaskState();
}

class _AddCOTITokenToMetaMaskState extends State<AddCOTITokenToMetaMask> {
  int currentStep = 0;

  List<Map<String, String>> getSteps(BuildContext context) {
    return [
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
  }

  void goToNext() {
    setState(() {
      if (currentStep < getSteps(context).length - 1) {
        currentStep++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('add_token.complete'))),
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
    final steps = getSteps(context);
    final step = steps[currentStep];
    final theme = Theme.of(context);

    return MainLayout(
      title: tr('add_token.title'),
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
                    step['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: step['link'] != null
                        ? () => _launchUrl(step['link']!)
                        : null,
                    child: SelectableText.rich(
                      TextSpan(
                        text: step['text'],
                        style: TextStyle(
                          fontSize: 16,
                          color: step['link'] != null
                              ? theme.colorScheme.secondary.withOpacity(0.9)
                              : theme.textTheme.bodyMedium?.color,
                          decoration: step['link'] != null ? TextDecoration.underline : null,
                        ),
                        recognizer: step['link'] != null
                            ? (TapGestureRecognizer()..onTap = () => _launchUrl(step['link']!))
                            : null,
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
            const SecurityNote(),
            const SizedBox(height: 20),
            const ContactAndDonate(),
          ],
        ),
      ),
    );
  }
}
