import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../widgets/mode_button.dart';
import '../widgets/profile_menu_button.dart';
import 'caregiver_dashboard.dart';
import 'guardian_dashboard.dart';
import 'senior_dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<MedCareState>().currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F7F3), Color(0xFFF8FCFC)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user == null ? 'Welcome' : 'Welcome, ${user.fullName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF083344),
                      ),
                    ),
                  ),
                  const ProfileMenuButton(),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF083344),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MedCare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'A three-mode care app for senior citizens, guardians, and caregivers.',
                      style: TextStyle(
                        color: Color(0xFFCCFBF1),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ModeButton(
                title: 'Senior Mode',
                subtitle:
                    'Medicine reminders, vitals tracking, nearby medicine delivery, and one-tap emergency help.',
                icon: Icons.favorite_rounded,
                colors: const [Color(0xFF2A9D8F), Color(0xFF1D6F86)],
                textColor: const Color(0xFF062C2A),
                subtitleColor: const Color(0xFF123F3B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SeniorDashboard()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ModeButton(
                title: 'Guardian Mode',
                subtitle:
                    'Status checks, verified vitals, medicine ordering, emergency contacts, and shared caregiver chat.',
                icon: Icons.shield_rounded,
                colors: const [Color(0xFFEF8354), Color(0xFFCC5803)],
                textColor: const Color(0xFF4A1E00),
                subtitleColor: const Color(0xFF6A2F0A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GuardianDashboard(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ModeButton(
                title: 'Caregiver Mode',
                subtitle:
                    'Caregiver tasks, wellbeing support, emergency contacts, and the same guardian chat feed.',
                icon: Icons.volunteer_activism_rounded,
                colors: const [Color(0xFFFFD7BA), Color(0xFFF08A4B)],
                textColor: const Color(0xFF4A1E00),
                subtitleColor: const Color(0xFF6A2F0A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverDashboard(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const _InfoCard(
                title: 'What this demo includes',
                points: [
                  'Daily medicines with notification scheduling',
                  'Blood pressure, sugar, and pulse logging across senior and guardian modes',
                  'Caregiver task checklist and community support wall',
                  'Shared guardian-caregiver chat and editable common emergency contacts',
                  'Medicine shopping, cart, payment, store selection, live delivery map, and order history',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.points});

  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            ...points.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(point, style: const TextStyle(height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
