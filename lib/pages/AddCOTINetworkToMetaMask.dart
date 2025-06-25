import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../layouts/main_layout.dart';
import '../theme/app_colors.dart';

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
          SnackBar(content: Text(tr('add_coti.tutorial_complete'))),
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

  @override
  Widget build(BuildContext context) {
    final current = steps[currentStep];

    return MainLayout(
      title: tr('add_coti.title'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              tr('add_coti.title'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.accent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    current['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    current['text']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryText,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
                ElevatedButton(
                  onPressed: goToNext,
                  child: Text(currentStep == steps.length - 1 ? tr('add_coti.finish') : tr('add_coti.next')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningBackground,
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: AppColors.warningBorder, width: 6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('add_coti.note_title'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warningText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('add_coti.note_intro'),
                    style: const TextStyle(color: AppColors.warningText),
                  ),
                  const SizedBox(height: 10),
                  Text(tr('add_coti.note_1'), style: const TextStyle(color: AppColors.warningText)),
                  Text(tr('add_coti.note_2'), style: const TextStyle(color: AppColors.warningText)),
                  Text(tr('add_coti.note_3'), style: const TextStyle(color: AppColors.warningText)),
                  Text(tr('add_coti.note_4'), style: const TextStyle(color: AppColors.warningText)),
                  const SizedBox(height: 12),
                  Text(tr('add_coti.note_closing'), style: const TextStyle(color: AppColors.warningText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}