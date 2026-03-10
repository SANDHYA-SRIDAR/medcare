import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Username and password are required.');
      return;
    }

    if (_isLogin) {
      final error = await context.read<MedCareState>().loginUser(
        username: username,
        password: password,
      );
      if (!mounted) {
        return;
      }
      if (error != null) {
        _showMessage(error);
      }
      return;
    }

    final fullName = _fullNameController.text.trim();
    final confirmPassword = _confirmPasswordController.text;
    if (fullName.isEmpty) {
      _showMessage('Full name is required to create a profile.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    final error = await context.read<MedCareState>().registerUser(
      fullName: fullName,
      username: username,
      password: password,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      _showMessage(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF083344),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MedCare Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'One common account unlocks Senior, Guardian, and Caregiver mode. Every username must be unique.',
                                style: TextStyle(
                                  color: Color(0xFFCCFBF1),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Login'),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Create Account'),
                            ),
                          ],
                          selected: {_isLogin},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _isLogin = selection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        if (!_isLogin) ...[
                          TextField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: Icon(
                            _isLogin
                                ? Icons.login_rounded
                                : Icons.person_add_alt_1_rounded,
                          ),
                          label: Text(_isLogin ? 'Login' : 'Create profile'),
                        ),
                        const SizedBox(height: 14),
                        Consumer<MedCareState>(
                          builder: (context, state, child) {
                            return Text(
                              state.registeredUsers.isEmpty
                                  ? 'No local account exists yet. Create one to continue.'
                                  : 'Local accounts on this device: ${state.registeredUsers.length}',
                              style: const TextStyle(color: Color(0xFF64748B)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
