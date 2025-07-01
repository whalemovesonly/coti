import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart'; // For launching URL

import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class GetAddressOfZNSDomain extends StatefulWidget {
  const GetAddressOfZNSDomain({super.key});

  @override
  State<GetAddressOfZNSDomain> createState() => _GetAddressOfZNSDomainState();
}

class _GetAddressOfZNSDomainState extends State<GetAddressOfZNSDomain> {
  final TextEditingController _controller = TextEditingController();
  String loadingStatus = '';
  String? resultAddress;

  Future<String?> fetchZnsAddress(String domainInput) async {
    if (domainInput.isEmpty || RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(domainInput)) {
      return null;
    }

    final cleanedDomain = domainInput.toLowerCase().endsWith('.coti')
        ? domainInput.substring(0, domainInput.length - 5)
        : domainInput;
    final proxyUrl = Uri.parse(
      'https://zns.bio/api/resolveDomain?chain=2632500&domain=$cleanedDomain',
    );

    try {
      final response = await http.get(proxyUrl);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('address')) {
          return data['address'];
        }
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }

  void _handleFetch() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loadingStatus = 'Fetching address...';
      resultAddress = null;
    });

    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        loadingStatus = 'Please enter a domain';
      });
      return;
    }

    final address = await fetchZnsAddress(input);

    setState(() {
      if (address != null) {
        loadingStatus = 'Success!';
        resultAddress = address;
      } else {
        loadingStatus = 'No address found or invalid input';
        resultAddress = null;
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _openExplorerLink(String address) async {
    final url = Uri.parse('https://mainnet.cotiscan.io/address/$address');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final text = theme.textTheme;

    return MainLayout(
      title: 'Get Address Of ZNS Domain',
      child: Container(
        padding: const EdgeInsets.all(0),
        color: color.background,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Enter ZNS Domain',
                    style: text.titleMedium?.copyWith(color: color.primary),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _handleFetch(),
                      style: text.bodyMedium?.copyWith(color: color.primary),
                      decoration: InputDecoration(
                        hintText: '.coti',
                        hintStyle: TextStyle(color: color.tertiary),
                        filled: true,
                        fillColor: color.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _handleFetch,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loadingStatus,
                    style: text.bodyMedium?.copyWith(color: color.tertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (resultAddress != null)
                    Column(
                      children: [
                        Text(
                          resultAddress!,
                          style: text.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(resultAddress!),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => _openExplorerLink(resultAddress!),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
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