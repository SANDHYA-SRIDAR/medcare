import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../widgets/profile_menu_button.dart';

class VitalsTrackerPage extends StatefulWidget {
  const VitalsTrackerPage({super.key, required this.guardianView});

  final bool guardianView;

  @override
  State<VitalsTrackerPage> createState() => _VitalsTrackerPageState();
}

class _VitalsTrackerPageState extends State<VitalsTrackerPage> {
  late final TextEditingController _bpController;
  late final TextEditingController _sugarController;
  late final TextEditingController _pulseController;
  late final TextEditingController _notesController;
  bool _confirmedByCaregiver = true;

  @override
  void initState() {
    super.initState();
    final reading = context.read<MedCareState>().latestReading;
    _bpController = TextEditingController(text: reading.bloodPressure);
    _sugarController = TextEditingController(
      text: reading.sugar.toStringAsFixed(0),
    );
    _pulseController = TextEditingController(text: reading.pulse.toString());
    _notesController = TextEditingController(text: reading.notes);
    _confirmedByCaregiver = context
        .read<MedCareState>()
        .vitalsConfirmedByCaregiver;
  }

  @override
  void dispose() {
    _bpController.dispose();
    _sugarController.dispose();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guardianView ? 'Vitals Review' : 'Vitals Tracker'),
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
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latest recorded vitals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text('Blood pressure: ${state.latestReading.bloodPressure}'),
                  Text(
                    'Sugar: ${state.latestReading.sugar.toStringAsFixed(0)} mg/dL',
                  ),
                  Text('Pulse: ${state.latestReading.pulse} bpm'),
                  Text('Updated: ${state.latestReading.formattedDate}'),
                  const SizedBox(height: 10),
                  Text(
                    state.latestReading.notes,
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _bpController,
            decoration: const InputDecoration(
              labelText: 'Blood pressure',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sugarController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Sugar level (mg/dL)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pulseController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pulse (bpm)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _confirmedByCaregiver,
            onChanged: (value) => setState(() => _confirmedByCaregiver = value),
            contentPadding: EdgeInsets.zero,
            title: const Text('Confirmed by caregiver'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () async {
              final sugar = double.tryParse(_sugarController.text.trim());
              final pulse = int.tryParse(_pulseController.text.trim());
              if (sugar == null ||
                  pulse == null ||
                  _bpController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter valid BP, sugar, and pulse values.'),
                  ),
                );
                return;
              }

              context.read<MedCareState>().updateVitals(
                bloodPressure: _bpController.text.trim(),
                sugar: sugar,
                pulse: pulse,
                notes: _notesController.text.trim(),
                confirmedByCaregiver: _confirmedByCaregiver,
              );

              await FirebaseService.instance.syncVitals({
                'bloodPressure': _bpController.text.trim(),
                'sugar': sugar,
                'pulse': pulse,
                'notes': _notesController.text.trim(),
                'confirmedByCaregiver': _confirmedByCaregiver,
              });

              await NotificationService.instance.showNow(
                id: 220,
                title: 'Vitals updated',
                body: widget.guardianView
                    ? 'Guardian reviewed the senior\'s vital readings.'
                    : 'Senior vital readings were updated successfully.',
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vitals saved and synced.')),
                );
              }
            },
            icon: const Icon(Icons.save_rounded),
            label: Text(widget.guardianView ? 'Save review' : 'Save vitals'),
          ),
        ],
      ),
    );
  }
}
