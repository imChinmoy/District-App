import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<UserModel?> signUp(
    String email,
    String password,
    String name,
  ) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user?.updateDisplayName(name);
    return result.user != null
        ? UserModel(
            uid: result.user!.uid,
            name: name,
            email: result.user!.email!,
          )
        : null;
  }

  static Future<UserModel?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    return user != null
        ? UserModel(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email!,
          )
        : null;
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static UserModel? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
    );
  }

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
