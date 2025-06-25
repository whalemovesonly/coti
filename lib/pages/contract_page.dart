import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../layouts/main_layout.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/styles/create_contract_styles.dart';

class ContractPage extends StatefulWidget {
  final String role;
  const ContractPage({super.key, required this.role});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contractorController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? fileName;
  String? fileURL;

  Future<String?> uploadFileToFirebase() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.bytes != null) {
      final Uint8List fileBytes = result.files.single.bytes!;
      final String originalName = result.files.single.name;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueName = '${timestamp}_$originalName';
      await FirebaseAuth.instance.currentUser?.getIdToken(true); // ⬅ force refresh
      final storageRef = FirebaseStorage.instance.ref().child('contracts/$uniqueName');
      final uploadTask = storageRef.putData(fileBytes);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        fileName = originalName;
        fileURL = downloadUrl;
      });

      return downloadUrl;
    }

    return null;
  }

Future<void> _saveContract() async {
  if (!_formKey.currentState!.validate()) return;

  // If no file was uploaded yet, upload now
  if (fileURL == null) {
    final uploadedUrl = await uploadFileToFirebase();
    if (uploadedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('upload_required'))),
      );
      return;
    }
  }

  await FirebaseFirestore.instance.collection('contracts').add({
    'name': nameController.text,
    'contractor': contractorController.text,
    'value': int.tryParse(valueController.text),
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'file_url': fileURL,
    'createdAt': DateTime.now().toIso8601String(),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(tr('saved'))),
  );

  _formKey.currentState!.reset();
  setState(() {
    startDate = null;
    endDate = null;
    fileName = null;
    fileURL = null;
  });
}

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    return MainLayout(
      title: tr('contract_title'), role: widget.role,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField(
                    controller: nameController,
                    icon: Icons.title,
                    label: tr('contract_name'),
                  ),
                  _buildTextField(
                    controller: contractorController,
                    icon: Icons.person,
                    label: tr('contractor'),
                  ),
                  _buildTextField(
                    controller: valueController,
                    icon: Icons.monetization_on,
                    label: tr('contract_value'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildDatePickerRow(
                    label: tr('start_date'),
                    date: startDate,
                    onTap: () => _pickDate(context, true),
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildDatePickerRow(
                    label: tr('end_date'),
                    date: endDate,
                    onTap: () => _pickDate(context, false),
                    icon: Icons.event,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final url = await uploadFileToFirebase();
                      if (url != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr('file_uploaded'))),
                        );
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text(fileName ?? tr('upload_contract_file')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14), textStyle: CreateContractButtonStyles.selectDateButton(context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _saveContract,
                    icon: const Icon(Icons.save),
                    label: Text(tr('save')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: CreateContractButtonStyles.selectDateButton(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        style: CreateContractTextStyles.inputText(context),
        validator: (v) => v == null || v.isEmpty ? tr('required') : null,
      ),
    );
  }

  Widget _buildDatePickerRow({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            date == null ? label : '$label: ${DateFormat('yyyy-MM-dd').format(date)}',
            style:  CreateContractTextStyles.inputText(context),
          ),
        ),
        ElevatedButton(
          onPressed: onTap,
          child: Text(label, style: CreateContractButtonStyles.selectDateButton(context)),
        ),
      ],
    );
  }
}