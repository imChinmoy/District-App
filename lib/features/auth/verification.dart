import 'package:district/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final isVerifiedProvider = StateProvider<bool>((ref) => false);
final isLoadingProvider = StateProvider<bool>((ref) => false);

class Verify extends ConsumerWidget {
  const Verify({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = ref.watch(isVerifiedProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor1,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Verification",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundColor1,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text(
                  'We have sent a verification link to your email.\n Please check your inbox and click on the link to verify your email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'reload',
            onPressed: null,
            tooltip: isVerified ? 'Verified' : 'Reload to Check Verification',
            backgroundColor: isVerified ? Colors.green : Colors.blueAccent,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'signout',
            onPressed: null,
            tooltip: 'Sign Out',
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
