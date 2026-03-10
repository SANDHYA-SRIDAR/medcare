import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../widgets/profile_menu_button.dart';
import 'caregiver_tasks.dart';
import 'chat_page.dart';
import 'emergency_page.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();
    final completedTasks = state.caregiverTasks
        .where((task) => task.done)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Mode'),
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD7BA), Color(0xFFF08A4B)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Caregiver workspace',
                  style: TextStyle(
                    color: Color(0xFF4A1E00),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.caregiverStatus,
                  style: const TextStyle(color: Color(0xFF6A2F0A), height: 1.4),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SummaryPill(
                      label: 'Tasks',
                      value: '$completedTasks/${state.caregiverTasks.length}',
                    ),
                    _SummaryPill(
                      label: 'Vitals',
                      value: state.vitalsConfirmedByCaregiver
                          ? 'Confirmed'
                          : 'Pending',
                    ),
                    _SummaryPill(label: 'Wellbeing', value: 'Shared'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DashboardTile(
            title: 'Caregiver tasks',
            subtitle:
                'Checklist, stress support, and caregiver wellbeing updates.',
            icon: Icons.fact_check_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CaregiverTasksPage()),
            ),
          ),
          const SizedBox(height: 14),
          _DashboardTile(
            title: 'Chat with guardian',
            subtitle:
                'Shared chat feed visible in both Guardian and Caregiver mode.',
            icon: Icons.forum_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatPage(senderRole: 'Caregiver'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DashboardTile(
            title: 'Emergency contacts',
            subtitle:
                'View and update the shared contact list used across all modes.',
            icon: Icons.contact_emergency_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmergencyPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF4A1E00)),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(18),
        leading: const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFFFF1E6),
          child: Icon(
            Icons.assignment_turned_in_rounded,
            color: Color(0xFFCC5803),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(subtitle, style: const TextStyle(height: 1.35)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
