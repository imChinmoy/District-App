import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/firebase/auth_service.dart';
import '../models/user_model.dart';
import '../database/repository/user_repo.dart';



final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(AuthService()),
);

final authProvider = StateNotifierProvider<AuthController, UserModel?>(
  (ref) => AuthController(ref.read(userRepositoryProvider)),
);

class AuthController extends StateNotifier<UserModel?> {
  final UserRepository _userRepository;

  AuthController(this._userRepository)
      : super(_userRepository.getCurrentUser());


  Future<void> login(String email, String password) async {
    try {
      final user = await _userRepository.login(email, password);
      if (user != null) state = user;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      final user = await _userRepository.signUp(email, password, name);
      if (user != null) state = user;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final user = await _userRepository.signInWithGoogle();
      state = user;
    } catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _userRepository.logout();
      state = null;
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }
}
