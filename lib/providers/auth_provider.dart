import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/firebase/auth_service.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthController, UserModel?>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<UserModel?> {
  AuthController() : super(_getInitialUser());

  static UserModel? _getInitialUser() {
    return AuthService.currentUser;
  }

  Future<void> login(String email, String password) async {
    final user = await AuthService.login(email, password);
    if (user != null) {
      state = user;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    final user = await AuthService.signUp(email, password, name);
    if (user != null) {
      state = user;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = null;
  }
}
