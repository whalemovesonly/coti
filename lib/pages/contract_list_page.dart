import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../layouts/main_layout.dart';

class ContractListPage extends StatelessWidget {
  final String role;
  const ContractListPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    context.locale;
    return MainLayout(
      title: tr('contract_list'),role: role,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contracts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(tr('no_contracts_found')));
          }

          final contracts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final data = contracts[index].data() as Map<String, dynamic>;
              final docId = contracts[index].id;

              final startDate = data['startDate'] != null
                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['startDate']))
                  : '-';
              final endDate = data['endDate'] != null
                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['endDate']))
                  : '-';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushNamed(context, '/contract-detail', arguments: {'docId':docId,'role':role});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.description_outlined, color: Colors.blueAccent, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data['name']} - ${data['contractor']}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('${tr('contract_value')}: ${data['value']} VNĐ'),
                              Text('${tr('start_date')}: $startDate'),
                              Text('${tr('end_date')}: $endDate'),
                              if (data['file_url'] != null && data['file_url'].toString().isNotEmpty)
                                TextButton.icon(
                                  onPressed: () async {
                                    final url = Uri.parse(data['file_url']);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(tr('cannot_open_url'))),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.download, size: 20),
                                  label: Text(tr('download_contract')),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}