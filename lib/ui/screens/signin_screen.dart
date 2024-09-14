import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_app/constants.dart';
import 'package:supabase_app/core/extensions/context_extension.dart';
import 'package:supabase_app/ui/screens/home_screen.dart';
import 'package:supabase_app/ui/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = 'SignInScreen';

  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  SupabaseClient supabase = Supabase.instance.client;

  bool _redirecting = false;
  bool _isLoading = false;
  bool _isChecked = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _emailController.text = 'marianz.bcssti@gmail.com';
    _passwordController.text = 'MarianzBcssti';
    supabase?.auth.onAuthStateChange.listen(
      (data) {
        if (_redirecting) return;
        final session = data.session;
        if (session != null) {
          _redirecting = true;
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
      },
      onError: (error) {
        if (error is AuthException) {
          context.showSnackBar(error.message);
        } else {
          context.showSnackBar('Unexpected error occurred');
        }
      },
    );
    super.initState();
  }

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await supabase?.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print(jsonEncode(response?.session));

      if (mounted) {
        _emailController.clear();
        _passwordController.clear();

        _redirecting = true;
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(error.message);
    } catch (error) {
      context.showErrorSnackBar('Unexpected error occurred $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      const webClientId = '46807533835-b30bdmgmjbpjf6eodpelt8k344hcok1i.apps.googleusercontent.com';
      const webserverClientId = '46807533835-ak5tj65gmbet554ns15ere2da258b3a6.apps.googleusercontent.com';
      final GoogleSignIn googleSignIn =  GoogleSignIn(
        clientId: webClientId,
        serverClientId: webserverClientId
      ) ;
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final idToken = googleAuth.idToken ?? googleAuth.accessToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken:  googleAuth.accessToken
      );
      if (mounted) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } on AuthException catch (error) {
      print('GOOGLE SIGNIN: AuthException $error');
      context.showErrorSnackBar(error.message);
    } catch (error) {
      print('GOOGLE SIGNIN: $error');
      context.showErrorSnackBar('Unexpected error occurred $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void onChanged(bool? value) {
    setState(() {
      _isChecked = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppColor.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 140, bottom: 60),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 35),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: '********',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(value: _isChecked, onChanged: onChanged),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 25),
                      const Flexible(
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 0, 84, 152),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    _isLoading ? 'Authenticating...' : 'Login',
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              _signIn();
                            }
                          },
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    'Continue with Google',
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await _googleSignIn();
                          },
                    iconImage: Image.asset('assets/google.png'),
                    isLoading: _isLoading,
                    backColor: Colors.black,
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
