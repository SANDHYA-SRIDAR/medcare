import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../widgets/profile_menu_button.dart';
import 'emergency_page.dart';
import 'medicine_order.dart';
import 'medicine_tracker.dart';
import 'vitals_tracker.dart';

class SeniorDashboard extends StatelessWidget {
  const SeniorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Senior Dashboard'),
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
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today at a glance',
                  style: TextStyle(
                    color: Color(0xFF062C2A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Latest BP ${state.latestReading.bloodPressure}  |  Sugar ${state.latestReading.sugar.toStringAsFixed(0)} mg/dL',
                  style: const TextStyle(
                    color: Color(0xFF123F3B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MetricChip(
                        label: 'Medicines',
                        value:
                            '${state.medications.where((item) => item.taken).length}/${state.medications.length}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricChip(
                        label: 'Delivery ETA',
                        value: '${state.etaMinutes} min',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _FeatureCard(
            title: 'Medicine tracker',
            subtitle:
                'View today\'s schedule and schedule daily push reminders.',
            icon: Icons.medication_rounded,
            color: const Color(0xFF2A9D8F),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicineTrackerPage()),
            ),
          ),
          const SizedBox(height: 14),
          _FeatureCard(
            title: 'Vitals tracker',
            subtitle: 'Log blood pressure, sugar, and pulse in one place.',
            icon: Icons.monitor_heart_rounded,
            color: const Color(0xFF0EA5E9),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VitalsTrackerPage(guardianView: false),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FeatureCard(
            title: 'Order medicines',
            subtitle:
                'Add medicines to cart and track delivery from nearby shops on the map.',
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFFEF8354),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicineOrderPage()),
            ),
          ),
          const SizedBox(height: 14),
          _FeatureCard(
            title: 'Emergency help',
            subtitle:
                'Call caregiver, guardian, ambulance, hospital, or a nearby friend quickly.',
            icon: Icons.sos_rounded,
            color: const Color(0xFFDC2626),
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF123F3B))),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF062C2A),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
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
