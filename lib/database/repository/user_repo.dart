import 'package:district/database/firebase/auth_service.dart';
import 'package:district/models/user_model.dart';

class UserRepository {
  final AuthService _authService;

  UserRepository(this._authService);

  UserModel? getCurrentUser() => _authService.currentUser;

  Future<UserModel?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<UserModel?> signUp(String email, String password, String name) async {
    return await _authService.signUp(email, password, name);
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final user = await _authService.signUsingGoogle();
      if (user == null) throw Exception("Google sign-in failed.");
      await _authService.saveUser(user);
      final currentUser = _authService.currentUser;
      if (currentUser == null) throw Exception("Failed to fetch current user.");
      return currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async => await _authService.logout();
}
