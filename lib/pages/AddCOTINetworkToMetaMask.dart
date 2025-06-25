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

  final List<Map<String, String>> steps = [
    {
      'title': "Step 1: Open MetaMask",
      'text': "Click the network dropdown at the top left of MetaMask and select 'Add a custom network'."
    },
    {
      'title': "Step 2: Enter COTI Mainnet Info",
      'text': """Fill in the fields with:\n\n
Network Name: COTI\n
RPC URL: https://mainnet.coti.io/rpc\n
Chain ID: 2632500\n
Symbol: COTI\n
Block Explorer: https://mainnet.cotiscan.io"""
    },
    {
      'title': "Step 3: Save & Switch",
      'text': "Click 'Save'. MetaMask will switch to the COTI network automatically."
    },
    {
      'title': "You're All Set!",
      'text': "You’ve added the COTI network to MetaMask. You can now bridge tokens or interact with dApps on COTI V2."
    },
  ];

  void goToNext() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tutorial complete!')),
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
      title: tr('AddCOTINetworkToMetaMask_title'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                  child: const Text("Back"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1f2833),
                    foregroundColor: const Color(0xFF66fcf1),
                    side: const BorderSide(color: Color(0xFF66fcf1)),
                  ),
                ),
                ElevatedButton(
                  onPressed: goToNext,
                  child: Text(currentStep == steps.length - 1 ? "Finish" : "Next"),
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
                  const Text(
                    "⚠️ Security Note for COTI Users",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF1E58D)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This website is 100% open-source and created for the COTI community to share technical instructions.",
                    style: TextStyle(color: Color(0xFFF1E58D)),
                  ),
                  const SizedBox(height: 10),
                  const Text("• All source code is available publicly on GitHub:", style: TextStyle(color: Color(0xFFF1E58D))),
                  GestureDetector(
                    onTap: () {
                      // TODO: use url_launcher to open external link if needed
                    },
                    child: const Text(
                      "https://github.com/whalemovesonly/coti",
                      style: TextStyle(
                        color: Color(0xFFF7DC6F),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("• The site loads directly from GitHub Pages — no hidden code or injected content.",
                      style: TextStyle(color: Color(0xFFF1E58D))),
                  const Text("• No wallet connection is required to view or use this site.",
                      style: TextStyle(color: Color(0xFFF1E58D))),
                  const Text(
                      "• We understand crypto users are cautious. Please feel free to inspect the code before clicking any links.",
                      style: TextStyle(color: Color(0xFFF1E58D))),
                  const SizedBox(height: 12),
                  const Text(
                    "✅ Stay safe, stay informed, and explore the COTI ecosystem with confidence.",
                    style: TextStyle(color: Color(0xFFF1E58D)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}