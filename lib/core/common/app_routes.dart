import 'package:flutter/material.dart';
import 'package:supabase_app/ui/pages.dart';
import 'package:supabase_app/ui/screens/account_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    SplashScreen.routeName: (context) => SplashScreen(),
    HomeScreen.routeName: (context) => HomeScreen(),
    AccountScreen.routeName: (context) => AccountScreen(),
    SignInScreen.routeName: (context) => SignInScreen(),
    SignUpScreen.routeName: (context) => SignUpScreen(),
  };
}
