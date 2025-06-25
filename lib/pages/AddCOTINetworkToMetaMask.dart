import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import 'package:easy_localization/easy_localization.dart';

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
                    color: const Color(0xFF66fcf1),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1f2833),
                border: Border.all(color: const Color(0xFF66fcf1), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    current['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF66fcf1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    current['text']!,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
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
                    backgroundColor: const Color(0xFF1f2833),
                    foregroundColor: const Color(0xFF66fcf1),
                    side: const BorderSide(color: Color(0xFF66fcf1)),
                  ),
                ),
                ElevatedButton(
                  onPressed: goToNext,
                  child: Text(currentStep == steps.length - 1 ? tr('add_coti.finish') : tr('add_coti.next')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1f2833),
                    foregroundColor: const Color(0xFF66fcf1),
                    side: const BorderSide(color: Color(0xFF66fcf1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3d2e00),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: Colors.amber[400]!, width: 6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('add_coti.note_title'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF1E58D)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('add_coti.note_intro'),
                    style: const TextStyle(color: Color(0xFFF1E58D)),
                  ),
                  const SizedBox(height: 10),
                  Text(tr('add_coti.note_1'), style: const TextStyle(color: Color(0xFFF1E58D))),
                  Text(tr('add_coti.note_2'), style: const TextStyle(color: Color(0xFFF1E58D))),
                  Text(tr('add_coti.note_3'), style: const TextStyle(color: Color(0xFFF1E58D))),
                  Text(tr('add_coti.note_4'), style: const TextStyle(color: Color(0xFFF1E58D))),
                  const SizedBox(height: 12),
                  Text(tr('add_coti.note_closing'), style: const TextStyle(color: Color(0xFFF1E58D))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}