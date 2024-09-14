import 'package:flutter/material.dart';
import 'package:supabase_app/constants.dart';
import 'package:supabase_app/core/extensions/context_extension.dart';
import 'package:supabase_app/core/navigator_context.dart';
import 'package:supabase_app/ui/screens/account_screen.dart';
import 'package:supabase_app/ui/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'signin_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SupabaseClient client = Supabase.instance.client;
  String name = '';
  bool isLoading = false;

  String userId = Supabase.instance.client.auth.currentUser?.id ?? '';

  getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user =  Supabase.instance.client.auth.currentUser;
      final profileImageUrl = user?.userMetadata?['avatar_url'];
      final fullName = user?.userMetadata?['full_name'];


      final data = await client.from('profiles').select().eq('id', user!.id).single();
      name = (data['username'] ?? data['full_name']) ?? fullName;
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message);
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar('Unexpected error occurred $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  logout() async {
    setState(() {
      isLoading = true;
    });

    try {
      await client.auth.signOut();
      if (client.auth.currentUser == null) {
        if (mounted) {
          context.showSnackBar("Log out successfully!");
        }
        NavigatorContext.go(SignInScreen.routeName);
      }
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar('Unexpected error occurred $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () {
                NavigatorContext.add(AccountScreen.routeName);
              },
              icon: const Icon(Icons.account_circle_sharp))
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 140, bottom: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome User! $name",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              name.isNotEmpty
                  ? CustomButton(
                      isLoading ? 'Logging-out...' : 'Logout',
                      onPressed: isLoading
                          ? null
                          : () async {
                              await logout();
                            },
                      isLoading: isLoading,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
