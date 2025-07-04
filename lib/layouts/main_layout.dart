import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../theme/theme_type.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  
  const MainLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
            color: Colors.white, // 👈 change this to any color you like
        ),
        title: Text(title, style: TextStyle(color: Colors.white),),
        elevation: 1,
        backgroundColor: const Color(0xFF041b46),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
              ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('gcotiforwallet.treasury_tracker_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/GCotiTreasuryTrackerPage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('gcotiforwalletoverview.treasury_chart_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/GCotiTreasuryOverviewPage');
              },
            ),

            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('gcotichart.chart_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/GCotiChartPage');
              },
            ),

            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('gcoti.page_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/GCotiDepositsPage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('cotiforwallet.treasury_tracker_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/CotiTreasuryTrackerPage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('cotiforwalletoverview.treasury_chart_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/CotiTreasuryOverviewPage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('cotichart.chart_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/CotiChartPage');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('coti.page_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/CotiDepositsPage');
              }),
              ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('znsaddress.title.get_zns_address')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/GetAddressOfZNSDomain');
              }),
              ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('znsdomains.title.get_zns_address')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/ZNSDomainsViewer');
              }),
              
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('add_coti.title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/AddCOTINetworkToMetaMask');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('add_token.title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/AddCOTITokenToMetaMask');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('buy_gcoti.title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/BuyGCOTIPage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fiber_manual_record),
              title: Text(tr('bridge_hack.title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/BridgeHackPage');
              },
            ),
            
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                context.locale.languageCode == 'en' ? 'French ' : 'English',
              ),
              onTap: () {
                final newLocale =
                    context.locale.languageCode == 'en' ? const Locale('fr') : const Locale('en');
                context.setLocale(newLocale);
                Navigator.pop(context);
              },
            ),

            Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, _) {
                return IconButton(
                  icon: Icon(
                    themeNotifier.currentTheme == AppThemeType.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: () {
                    themeNotifier.toggleTheme();
                  },
                );
              },
            ),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: child,
      ),
    );
  }
}