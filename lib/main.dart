import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth_page.dart';
import 'screens/home.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  final state = MedCareState();
  await state.initializeSession();
  runApp(MedCareApp(state: state));
}

class MedCareApp extends StatelessWidget {
  const MedCareApp({super.key, this.state});

  final MedCareState? state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MedCareState>.value(
      value: state ?? MedCareState(),
      child: MaterialApp(
        title: 'MedCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2A9D8F),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6FBFA),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.white,
          ),
        ),
        home: const RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedCareState>(
      builder: (context, state, child) {
        return state.isLoggedIn ? const HomePage() : const AuthPage();
      },
    );
  }
}
