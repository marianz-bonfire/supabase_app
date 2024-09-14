import 'package:flutter/material.dart';
import 'package:supabase_app/core/common/app_routes.dart';
import 'package:supabase_app/ui/pages.dart';
import 'package:supabase_app/core/common/app_preference.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/navigator_context.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://****.supabase.co',
    anonKey: 'eyJhbG3NmO*******c',
  );

  await AppPreference.instance.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigatorContext.key,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: AppRoutes.routes,
    );
  }
}
