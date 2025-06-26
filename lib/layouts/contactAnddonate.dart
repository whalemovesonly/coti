import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class ContactAndDonate extends StatelessWidget {
  const ContactAndDonate({super.key});

  void _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('donate.link_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            tr('donate.title'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('donate.message'),
            style: TextStyle(color: theme.colorScheme.tertiary),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(color: theme.colorScheme.tertiary),
              children: [
                TextSpan(text: tr('donate.domain_prefix')),
                TextSpan(
                  text: 'whalemovesonly.coti',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchUrl(context, 'https://zns.bio/whalemovesonly.coti'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tr('donate.contact_intro'),
            style: TextStyle(color: theme.colorScheme.tertiary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '📧 whalemovesonly@gmail.com',
            style: TextStyle(color: theme.colorScheme.tertiary),
          ),
          GestureDetector(
            onTap: () => _launchUrl(context, 'https://x.com/whalemovesonly'),
            child: Text(
              '🐦 x.com/whalemovesonly',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _launchUrl(context, 'https://t.me/whalemovesonly'),
            child: Text(
              '💬 t.me/whalemovesonly',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}