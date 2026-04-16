// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showRegister = false;
  bool _resetPasswordLoading = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    // Validate email format
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _resetPasswordLoading = true;
    });

    await Provider.of<AppProvider>(context, listen: false)
        .resetPassword(_emailController.text);

    if (mounted) {
      setState(() {
        _resetPasswordLoading = false;
      });

      final error = Provider.of<AppProvider>(context, listen: false).authError;
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password reset email sent. Check your inbox.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: kIndigo,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Attendance Master Scholar',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kIndigo,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showRegister
                              ? 'Create your account'
                              : 'Sign in to continue',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_showRegister) ...[
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                                autofillHints: const [AutofillHints.name],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              autofillHints: const [AutofillHints.email],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              autofillHints: const [AutofillHints.password],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Error message
                            Consumer<AppProvider>(
                              builder: (context, provider, child) {
                                if (provider.authError != null) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.red[200]!),
                                    ),
                                    child: Text(
                                      provider.authError!,
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Login Button
                            Consumer<AppProvider>(
                              builder: (context, provider, child) {
                                return ElevatedButton(
                                  onPressed: provider.isLoading ||
                                          _resetPasswordLoading
                                      ? null
                                      : () async {
                                          FocusScope.of(context).unfocus();
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (_showRegister) {
                                              await provider.register(
                                                _nameController.text,
                                                _emailController.text,
                                                _passwordController.text,
                                              );
                                            } else {
                                              await provider.login(
                                                _emailController.text,
                                                _passwordController.text,
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kIndigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _showRegister
                                              ? 'Create Account'
                                              : 'Sign In',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Google Sign-in Button
                            Consumer<AppProvider>(
                              builder: (context, provider, child) {
                                return OutlinedButton.icon(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          await provider.signInWithGoogle();
                                        },
                                  icon: const Icon(Icons.login, size: 24),
                                  label: const Text('Sign in with Google'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Anonymous Sign-in Button
                            Consumer<AppProvider>(
                              builder: (context, provider, child) {
                                return TextButton.icon(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          await provider.signInAnonymously();
                                        },
                                  icon: const Icon(Icons.person_outline,
                                      size: 20),
                                  label: const Text('Continue as Guest'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    foregroundColor: Colors.grey[600],
                                  ),
                                );
                              },
                            ),

                            if (!_showRegister) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _resetPasswordLoading
                                    ? null
                                    : _handleForgotPassword,
                                child: _resetPasswordLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Forgot Password?'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register / Login toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showRegister
                            ? 'Already have an account?'
                            : "Don't have an account?",
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showRegister = !_showRegister;
                            _nameController.clear();
                            _emailController.clear();
                            _passwordController.clear();
                            _formKey.currentState?.reset();
                            Provider.of<AppProvider>(context, listen: false)
                                .clearAuthError();
                          });
                        },
                        child:
                            Text(_showRegister ? 'Sign In' : 'Create Account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
