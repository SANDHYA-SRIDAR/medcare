import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../widgets/profile_menu_button.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  Future<void> _showContactEditor(BuildContext context, {int? index}) async {
    final state = context.read<MedCareState>();
    final existing = index == null ? null : state.emergencyContacts[index];
    final labelController = TextEditingController(text: existing?.label ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                index == null
                    ? 'Add emergency contact'
                    : 'Edit emergency contact',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Contact label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final label = labelController.text.trim();
                  final phone = phoneController.text.trim();
                  if (label.isEmpty || phone.isEmpty) {
                    return;
                  }
                  if (index == null) {
                    state.addEmergencyContact(label: label, phone: phone);
                  } else {
                    state.updateEmergencyContact(
                      index,
                      label: label,
                      phone: phone,
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(index == null ? 'Add contact' : 'Save changes'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProfileMenuButton(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Use this shared list in all modes for urgent support. Contacts can be edited and new emergency numbers can be added at any time.',
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(state.emergencyContacts.length, (index) {
            final contact = state.emergencyContacts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFEE2E2),
                    child: Icon(contact.icon, color: const Color(0xFFDC2626)),
                  ),
                  title: Text(
                    contact.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(contact.phone),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _showContactEditor(context, index: index),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await NotificationService.instance.showNow(
                            id: contact.phone.hashCode,
                            title: 'Emergency action started',
                            body: 'Attempting to contact ${contact.label}.',
                          );
                          final uri = Uri.parse('tel:${contact.phone}');
                          await launchUrl(uri);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                        ),
                        child: const Text('Call'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _showContactEditor(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add emergency contact'),
          ),
        ],
      ),
    );
  }
}
