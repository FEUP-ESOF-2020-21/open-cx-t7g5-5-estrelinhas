import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User> get authStateChanges => _auth.authStateChanges();
  
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> signIn({String email, String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed In";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return "Signed Up";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}