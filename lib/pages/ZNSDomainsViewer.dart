import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../layouts/main_layout.dart';
import '../layouts/SecurityNote.dart';
import '../layouts/contactAnddonate.dart';

class ZNSDomainsViewer extends StatefulWidget {
  const ZNSDomainsViewer({super.key});

  @override
  State<ZNSDomainsViewer> createState() => _ZNSDomainsViewerState();
}

class _ZNSDomainsViewerState extends State<ZNSDomainsViewer> {
  final TextEditingController _controller = TextEditingController();
  String? loadingStatusKey;
  List<String> domains = [];
  bool hasPrimary = false;

  bool isLoading = false;

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

  Future<Map<String, dynamic>?> fetchZnsDomainsOfAnAddress(String address) async {
    if (address.isEmpty || !RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) {

      if(!address.isEmpty && !RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address))
      {
              final tmp = address;
              final address1 = address;
              final address2 = await fetchZnsAddress(address1); // or 'example.coti'
              if (address2 != null)
              {
                  address = address2;
              }else
              {
                address = tmp;
              }
              print('===>>>>>>>>address: $address');
      }else
      {
              return null;
      }
    }

    final proxyUrl = Uri.parse(
      'https://zns.bio/api/resolveAddress?chain=2632500&address=$address',
    );

    try {
      final response = await http.get(proxyUrl);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<String> domains = [];
        final primaryDomain = json['primaryDomain'];
        final hasPrimary = primaryDomain != null && primaryDomain.toString().isNotEmpty;

        if (hasPrimary) {
          domains.add(primaryDomain.toString());
        }

        if (json['userOwnedDomains'] is List) {
          for (var domain in json['userOwnedDomains']) {
            if (domain is String &&
                domain.isNotEmpty &&
                (!hasPrimary || domain != primaryDomain)) {
              domains.add(domain);
            }
          }
        }

        return {
          'domains': domains,
          'hasPrimary': hasPrimary,
        };
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
      loadingStatusKey = 'znsdomains.status.fetching';
      domains = [];
      hasPrimary = false;
      isLoading = true;
    });

    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        loadingStatusKey = 'znsdomains.status.empty_input';
        isLoading = false;
      });
      return;
    }

    final result = await fetchZnsDomainsOfAnAddress(input);

    setState(() {
      if (result != null && result['domains'] is List<String>) {
        domains = List<String>.from(result['domains']);
        hasPrimary = result['hasPrimary'] == true;
        loadingStatusKey = 'znsdomains.status.success';
      } else {
        loadingStatusKey = 'znsdomains.status.not_found';
        domains = [];
        hasPrimary = false;
      }
      isLoading = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('znsdomains.clipboard.copied'))),
    );
  }

  void _openExplorerLink(String domain) async {
    final url = Uri.parse('https://zns.bio/$domain');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('znsdomains.error.cannot_open_link'))),
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
      title: tr('znsdomains.title.get_zns_address'),
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
                    tr('znsdomains.label.enter_zns_domain'),
                    style: text.titleMedium?.copyWith(color: color.primary),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _controller,
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleFetch(),
                      style: text.bodyMedium?.copyWith(color: color.primary),
                      decoration: InputDecoration(
                        hintText: tr('znsdomains.hint.coti_domain'),
                        hintStyle: TextStyle(color: color.tertiary),
                        filled: true,
                        fillColor: color.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: isLoading ? null : _handleFetch,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (loadingStatusKey != null)
                    Text(
                      loadingStatusKey!.tr(),
                      style: text.bodyMedium?.copyWith(color: color.tertiary),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  if (domains.isNotEmpty)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: domains.map((domain) {
                        final isPrimary = hasPrimary && domain == domains.first;
                        return Card(
                          color: isPrimary ? color.primaryContainer : color.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: isPrimary ? 6 : 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  domain,
                                  style: text.titleMedium?.copyWith(
                                    color: isPrimary ? color.onPrimaryContainer : color.primary,
                                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      tooltip: tr('znsdomains.button.copy'),
                                      onPressed: () => _copyToClipboard(domain),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      tooltip: tr('znsdomains.button.open'),
                                      onPressed: () => _openExplorerLink('$domain.coti'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else if (loadingStatusKey == 'znsdomains.status.success')
                    Text(
                      tr('znsdomains.status.not_found'),
                      style: text.bodyMedium?.copyWith(color: color.tertiary),
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