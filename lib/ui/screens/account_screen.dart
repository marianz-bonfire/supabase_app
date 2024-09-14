import 'package:flutter/material.dart';
import 'package:supabase_app/constants.dart';
import 'package:supabase_app/core/extensions/context_extension.dart';
import 'package:supabase_app/core/navigator_context.dart';
import 'package:supabase_app/ui/screens/signin_screen.dart';
import 'package:supabase_app/ui/widgets/avatar.dart';
import 'package:supabase_app/ui/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = 'AccountScreen';
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();

  SupabaseClient supabase = Supabase.instance.client;

  String? _avatarUrl;
  bool _loading = true;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      User? user = Supabase.instance.client.auth.currentSession?.user;
      user ??= Supabase.instance.client.auth.currentUser;
      final data = await supabase.from('profiles').select().eq('id', user!.id).single();
      if (data != null && (data['username'] ?? '').toString().isNotEmpty) {
        _usernameController.text = (data['username'] ?? '') as String;
        _websiteController.text = (data['website'] ?? '') as String;
        _avatarUrl = (data['avatar_url'] ?? '') as String;
      } else {
        _usernameController.text = (user?.userMetadata?['full_name'] ?? '') as String;
        _websiteController.text = (user?.userMetadata?['website'] ?? '') as String;
        _avatarUrl = (user?.userMetadata?['avatar_url'] ?? '') as String;
      }
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message);
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar('Unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userName = _usernameController.text.trim();
    final website = _websiteController.text.trim();
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'username': userName,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) context.showSnackBar('Successfully updated profile!');
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred');
      }
    } finally {
      if (mounted) {
        NavigatorContext.go(SignInScreen.routeName);
      }
    }
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        context.showSnackBar('Updated your profile image!');
      }
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred');
      }
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColor.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          Avatar(
            imageUrl: _avatarUrl,
            onUpload: _onUpload,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'User Name'),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website'),
          ),
          const SizedBox(height: 18),
          CustomButton(
            _loading ? 'Saving...' : 'Update',
            onPressed: _loading ? null : _updateProfile,
            isLoading: _loading,
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: _signOut,
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
