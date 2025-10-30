import 'package:flutter/material.dart';
import '../main.dart';
import '../database_helper.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;
  String? _error; 

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUser(_emailCtrl.text.trim());

      if (user == null || user['password'] != _passCtrl.text.trim()) {
        setState(() {
          _error = 'Invalid email or password.';
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in!')),
        );

        // Navigate to your app’s home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => Dashboard(user: user)),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Password is required';
    if (s.length < 6) return 'Minimum 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Go back'),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => OnboardingScreen()),
                              );
                            },
                          ),
                        ),
                        Image.asset( 'assets/logo_apka.png', height: 140), 
                        const SizedBox(height: 12),
                        Text('Welcome back',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text('Sign in to continue',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),

                        if (_error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'you@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _obscure = !_obscure),
                              tooltip: _obscure ? 'Show password' : 'Hide password',
                            ),
                          ),
                          validator: _validatePassword,
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged: (v) => setState(() => _remember = v ?? true),
                            ),
                            const Text('Remember me'),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // TODO: navigate to forgot password screen
                              },
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _loading ? null : _onSubmit,
                            child: _loading
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 6),
                                    child: SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or', style: Theme.of(context).textTheme.bodySmall),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Social auth placeholders (wire up later)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {/* TODO: Google sign-in */},
                                icon: const Icon(Icons.g_mobiledata),
                                label: const Text('Google'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {/* TODO: Apple sign-in */},
                                icon: const Icon(Icons.apple),
                                label: const Text('Apple'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                // TODO: navigate to sign-up
                              },
                              child: const Text('Create one'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () async {
                            final dbHelper = DatabaseHelper();
                            final id = await dbHelper.insertUser("test@gmail.com", "password123", "Test User");
                            print("Test user created with ID: $id");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("User 'test@gmail.com' created a with password 'password123'")),
                            );
                          },
                          child: const Text("Create Test User"),
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
