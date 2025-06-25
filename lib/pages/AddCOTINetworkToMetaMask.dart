import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import 'package:easy_localization/easy_localization.dart';

class AddCOTINetworkToMetaMask extends StatelessWidget {
  const AddCOTINetworkToMetaMask({super.key});

  @override
  Widget build(BuildContext context) {
    context.locale;
    return MainLayout(
      title: tr('AddCOTINetworkToMetaMask_title'),
      child: Center(
        child: Text(tr('AddCOTINetworkToMetaMask_title'), style: TextStyle(color: Colors.white),),
      ),
    );
  }
}