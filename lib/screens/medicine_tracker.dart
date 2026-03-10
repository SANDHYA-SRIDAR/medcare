import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../widgets/profile_menu_button.dart';

class MedicineTrackerPage extends StatelessWidget {
  const MedicineTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Tracker'),
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
              color: const Color(0xFFDFF7F3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Use the reminder button on any medicine to schedule a daily push notification. Mark medicines as taken to help guardians review adherence.',
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(state.medications.length, (index) {
            final item = state.medications[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('${item.dose}  |  ${item.formattedTime}'),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: item.taken,
                            onChanged: (_) => context
                                .read<MedCareState>()
                                .toggleMedication(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await NotificationService.instance
                                    .scheduleDailyMedicationReminder(
                                      id: index,
                                      medication: item.name,
                                      time: item.time,
                                    );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Daily reminder set for ${item.name} at ${item.formattedTime}.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.notifications_active_rounded,
                              ),
                              label: const Text('Set reminder'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                await NotificationService.instance.showNow(
                                  id: 100 + index,
                                  title: 'Medicine check-in',
                                  body:
                                      '${item.name} marked as taken for today.',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Check-in notification sent.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.done_all_rounded),
                              label: const Text('Notify caregiver'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
