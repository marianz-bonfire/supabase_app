import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_app/constants.dart';
import 'package:supabase_app/core/extensions/context_extension.dart';
import 'package:supabase_app/core/navigator_context.dart';
import 'package:supabase_app/ui/screens/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/common/app_preference.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = 'SignUpScreen';
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SupabaseClient supabase = Supabase.instance.client;

  bool _redirecting = false;
  bool isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
    super.initState();
  }

  Future<void> _signUp() async {
    try {
      setState(() {
        isLoading = true;
      });
      AuthResponse response =
          await supabase.auth.signUp(password: _passwordController.text, email: _emailController.text);
      if (mounted) {
        _redirecting = true;
        _saveId(response.user);
        NavigatorContext.go(SignInScreen.routeName).then((value) => context.showSnackBar("Verify your email!"));
      }
      setState(() {
        isLoading = false;
      });
    } on AuthException catch (error) {
      setState(() {
        isLoading = false;
      });
      context.showErrorSnackBar(error.message);
    } catch (error) {
      context.showErrorSnackBar('Unexpected error occurred $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppColor.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      labelText: 'Email',
                      hintText: 'Enter a valid email'),
                  validator: (String? value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Email is not valid';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      labelText: 'Password',
                      hintText: 'Enter your password'),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Invalid password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  obscureText: true,
                  controller: _confPasswordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      labelText: 'Confirm Password',
                      hintText: 'Enter your password again'),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Invalid password';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_passwordController.text == _confPasswordController.text) {
                        _signUp();
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Passwords didn't match! Try again.")));
                      }
                    }
                  },
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                ),
              ),
              const SizedBox(
                height: 130,
              ),
              TextButton(
                onPressed: () {
                  NavigatorContext.go(SignInScreen.routeName);
                },
                child: const Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _saveId(User? user) async {
    //await AppPreference().setString('userId', user?.id ?? '');
    await AppPreference.instance.setString('userId', user?.id ?? '');
  }
}
