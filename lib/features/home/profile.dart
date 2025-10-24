import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){
                  log('tap');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    child: user?.profileImageUrl?.isNotEmpty ?? false
                        ? Image.network(user!.profileImageUrl!)
                        : const Icon(Icons.person),
                  ),
                ),
              ),
              title: Text(user?.name ?? ''),
              dense: false,
              trailing: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
