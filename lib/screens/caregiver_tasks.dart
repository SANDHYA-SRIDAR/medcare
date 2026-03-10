import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../widgets/profile_menu_button.dart';

class CaregiverTasksPage extends StatefulWidget {
  const CaregiverTasksPage({super.key});

  @override
  State<CaregiverTasksPage> createState() => _CaregiverTasksPageState();
}

class _CaregiverTasksPageState extends State<CaregiverTasksPage> {
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _ventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<MedCareState>();
    _statusController.text = state.caregiverStatus;
  }

  @override
  void dispose() {
    _statusController.dispose();
    _ventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Tasks'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProfileMenuButton(),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: FirebaseService.instance.fetchStressTips(),
        builder: (context, snapshot) {
          final tips = snapshot.data ?? const <String>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Daily task checklist',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...List.generate(state.caregiverTasks.length, (index) {
                final task = state.caregiverTasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CheckboxListTile(
                      value: task.done,
                      onChanged: (_) =>
                          context.read<MedCareState>().toggleTask(index),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(task.subtitle),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              TextField(
                controller: _statusController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Caregiver status update',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  context.read<MedCareState>().updateCaregiverStatus(
                    _statusController.text.trim(),
                  );
                  await FirebaseService.instance.syncCaregiverStatus(
                    _statusController.text.trim(),
                  );
                  await NotificationService.instance.showNow(
                    id: 330,
                    title: 'Caregiver status updated',
                    body: _statusController.text.trim(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status shared with guardians.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.publish_rounded),
                label: const Text('Share status'),
              ),
              const SizedBox(height: 18),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Caregiver health and venting space',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Current wellbeing note: ${state.caregiverWellbeing}',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ventController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Share stress, ask for help, or post a coping tip...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () {
                          context.read<MedCareState>().updateCaregiverWellbeing(
                            _ventController.text.trim(),
                          );
                          context.read<MedCareState>().addSupportPost(
                            'You',
                            _ventController.text.trim(),
                          );
                          _ventController.clear();
                        },
                        child: const Text('Post to support wall'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (tips.isNotEmpty) ...[
                const Text(
                  'Stress support tips',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(tip),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Community board',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...state.supportPosts.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(18),
                      title: Text(
                        post.author,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${post.message}\n${post.timeLabel}',
                          style: const TextStyle(height: 1.45),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
