import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  late final AnimationController _logoController;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all fields properly.');
      return;
    }

    setState(() => _isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    try {
      if (isLogin) {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          _showSnackBar("Login successful!");
          _navigateToHome();
        } else {
          _showSnackBar("Login failed. Please try again.");
        }
      } else {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final userId = response.user?.id;

        if (userId != null) {
          final profileData = {
            'id': userId,
            'username': username,
            'email': email,
          };

          final updateResponse = await supabase
              .from('profiles')
              .update({'username': username})
              .eq('id', userId);

          if (updateResponse.status == 404) {
            await supabase.from('profiles').insert(profileData);
          }

          _showSnackBar('Signup successful! Please check your email.');
          _navigateToHome();
        } else {
          _showSnackBar('Please confirm your email before logging in.');
        }
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Something went wrong: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    emailController.clear();
    usernameController.clear();
    passwordController.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'auth-logo',
                  child: FadeTransition(
                    opacity: _logoController,
                    child: const Icon(Icons.lock, size: 60, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: Text(
                    isLogin ? 'Login' : 'Sign Up',
                    key: ValueKey(isLogin),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Username (signup only)
                        if (!isLogin) ...[
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username is required';
                              }
                              if (value.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Loading spinner or button
                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.green)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: _authenticate,
                                child: Text(
                                  isLogin ? 'Login' : 'Sign Up',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                        const SizedBox(height: 16),

                        // Toggle text
                        TextButton(
                          onPressed: () {
  _formKey.currentState?.reset(); // Reset form validation
  emailController.clear();
  usernameController.clear();
  passwordController.clear();

  setState(() {
    isLogin = !isLogin;
  });
},

                          child: Text(
                            isLogin
                                ? "Don't have an account? Sign up"
                                : "Already have an account? Login",
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
