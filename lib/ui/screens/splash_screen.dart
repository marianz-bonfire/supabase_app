import 'package:flutter/material.dart';
import 'package:supabase_app/ui/pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/navigator_context.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'SplashScreen';
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _redirectCalled = false;
  SupabaseClient supabase = Supabase.instance.client;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (_redirectCalled || !mounted) {
      return;
    }

    _redirectCalled = true;
    final session = supabase.auth.currentSession;
    if (session != null) {
      //Navigator.of(context).pushReplacementNamed('/home');
      NavigatorContext.go(HomeScreen.routeName);
    } else {
      //Navigator.of(context).pushReplacementNamed('/login');
      NavigatorContext.go(SignInScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
