import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

 void _authenticate() async {
  print('_authenticate method called');
  if (_formKey.currentState?.validate() ?? false) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    print('Form is valid. Email: $email, Username: $username');

    if (isLogin) {
      print('Attempting to login');
      try {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        print('Login response: ${response.user}');
        if (response.user != null) {
          _showSnackBar("Login successful!");
          _navigateToHome();
        } else {
          _showSnackBar("Login failed. Please try again.");
        }
      } on AuthException catch (e) {
        print('Login failed with AuthException: ${e.message}');
        _showSnackBar('Invalid email or password: ${e.message}');
      } catch (e) {
        print('Login failed with unexpected error: $e');
        _showSnackBar('Something went wrong. Please try again: $e');
      }
    } else {
      print('Attempting to sign up');
      try {
        // First, sign up the user
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        print('Sign up response: ${response.user}');
        final authUser = response.user;
        final userId = response.user?.id;

        if (userId != null) {
          try {
            // Prepare the profile data
            final profileData = {
              'id': userId,
              'username': username,
              'email': email,
            };

            // First try to update the profile in case it exists
            final updateResponse = await supabase
                .from('profiles')
                .update({'username': username})
                .eq('id', userId);

            print('Profile update response status: ${updateResponse.status}');

            // If the update didn't find a record (status code 404), try to insert
            if (updateResponse.status == 404) {
              print('Profile not found, attempting to insert');
              final insertResponse = await supabase
                  .from('profiles')
                  .insert(profileData);

              print('Profile insert response status: ${insertResponse.status}');

              if (insertResponse.error != null) {
                print('Profile insert error: ${insertResponse.error!.message}');
                _showSnackBar('Failed to create profile: ${insertResponse.error!.message}');
              }
            } else if (updateResponse.error != null) {
              print('Profile update error: ${updateResponse.error!.message}');
              _showSnackBar('Failed to update profile: ${updateResponse.error!.message}');
            }

            // Show success message regardless of profile operation success
            // since the user was successfully created
            _showSnackBar('Signup successful!');
            _navigateToHome();
          } catch (e) {
            print('Profile operation failed: $e');
            // Even if profile operation fails, the user is still created
            // So we show a warning but still consider the signup successful
            
            _navigateToHome();
          }
        } else {
          _showSnackBar('Please check your email to confirm your account before logging in.');
        }
      } on AuthException catch (e) {
        print('Sign up failed with AuthException: ${e.message}');
        _showSnackBar('Email already registered. Please log in: ${e.message}');
      } catch (e) {
        print('Sign up failed with unexpected error: $e');
        _showSnackBar('Something went wrong. Please try again: $e');
      }
    }
  } else {
    print('Form is not valid');
    _showSnackBar('Please fill all fields properly.');
  }
}


  void _navigateToHome() {
    print('_navigateToHome method called');
    emailController.clear();
    usernameController.clear();
    passwordController.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showSnackBar(String message) {
    print('_showSnackBar called with message: $message');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    print('dispose method called');
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build method called');
  return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  body: Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLogin ? 'Login' : 'Sign Up',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

                const SizedBox(height: 32),

                // Email
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
  onChanged: (value) {
    print('Email field changed: $value');
  },
),

                const SizedBox(height: 16),

                // Username (only for sign up)
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
  onChanged: (value) {
    print('Username field changed: $value');
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
        _obscurePassword ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
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
  onChanged: (value) {
    print('Password field changed');
  },
),

                const SizedBox(height: 32),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    print('Authenticate button pressed');
                    _authenticate();
                  },
                  child: Text(
                    isLogin ? 'Login' : 'Sign Up',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    print('Toggle auth mode button pressed');
                    setState(() {
                      isLogin = !isLogin;
                      emailController.clear();
                      usernameController.clear();
                      passwordController.clear();
                      _formKey.currentState?.reset();
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
      ),
    );
  }
}