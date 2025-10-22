import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  Future<UserModel?> signUp(
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

  Future<UserModel?> signUsingGoogle() async {

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user != null
        ? UserModel(
            uid: result.user!.uid,
            name: result.user!.displayName ?? '',
            email: result.user!.email!,
          )
        : null;
  }

  Future<UserModel?> saveUser( UserModel? user) async {
    if (user == null) return null;
    await _auth.currentUser?.updateDisplayName(user.name);
    return user;
  }

  Future<UserModel?> login(String email, String password) async {
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

  Future<void> logout() async {
    await _auth.signOut();
  }

  UserModel? get currentUser {
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
