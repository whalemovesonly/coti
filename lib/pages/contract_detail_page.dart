import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

class ContractDetailPage extends StatelessWidget {
  final String role;
  const ContractDetailPage({super.key, required this.role});

  Future<DocumentSnapshot> _fetchContract(String id) {
    return FirebaseFirestore.instance.collection('contracts').doc(id).get();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String contractId = args['docId'];

    return Scaffold(
      appBar: AppBar(title: Text(tr('contract_detail'))),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchContract(contractId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text(tr('contract_not_found')));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final startDate = data['startDate'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['startDate']))
              : '-';
          final endDate = data['endDate'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['endDate']))
              : '-';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description_outlined, color: Colors.blue, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data['name'] ?? '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    _buildDetailRow(context, Icons.person_outline, tr('contractor'), data['contractor']),
                    _buildDetailRow(context, Icons.monetization_on_outlined, tr('contract_value'), '${data['value']} VNĐ'),
                    _buildDetailRow(context, Icons.calendar_today_outlined, tr('start_date'), startDate),
                    _buildDetailRow(context, Icons.event_note_outlined, tr('end_date'), endDate),
                    const SizedBox(height: 20),
                    if (data['file_url'] != null && data['file_url'].toString().isNotEmpty)
                      ElevatedButton.icon(
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
                        icon: const Icon(Icons.download),
                        label: Text(tr('download_contract')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}