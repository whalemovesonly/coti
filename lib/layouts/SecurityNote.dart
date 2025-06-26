import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/gestures.dart';

import '../theme/theme_notifier.dart';
import '../theme/themes.dart';
import '../theme/theme_type.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../theme/theme_type.dart';

class SecurityNote extends StatelessWidget {
  const SecurityNote({super.key});


  Future<void> _launchGitHub(BuildContext context) async {
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
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: theme.colorScheme.tertiary, width: 6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('add_coti.note_title'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('add_coti.note_intro'),
                    style: TextStyle(color: theme.colorScheme.tertiary),
                  ),
                  const SizedBox(height: 10),

                  // GitHub RichText link in note_1
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: theme.colorScheme.tertiary),
                      children: [
                        TextSpan(text: tr('add_coti.note_1_part1')),
                        TextSpan(
                          text: 'GitHub',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () => _launchGitHub(context),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),

                  Text(tr('add_coti.note_2'), style: TextStyle(color: theme.colorScheme.tertiary)),
                  Text(tr('add_coti.note_3'), style: TextStyle(color: theme.colorScheme.tertiary)),
                  Text(tr('add_coti.note_4'), style: TextStyle(color: theme.colorScheme.tertiary)),
                  const SizedBox(height: 12),
                  Text(tr('add_coti.note_closing'), style: TextStyle(color: theme.colorScheme.tertiary)),
                ],
              ),
            );
  }
}