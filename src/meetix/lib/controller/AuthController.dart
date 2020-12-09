import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  User get currentUser => _auth.currentUser;

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

  Future<String> signUp({String email, String password, String displayName}) async {
    try {
      var user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      await _auth.currentUser.updateProfile(displayName: displayName);
      await _auth.currentUser.reload();
      return "Signed Up";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> deleteAccount({String password}) async {
    try {
      EmailAuthCredential credential = EmailAuthProvider.credential(email: currentUser.email, password: password);
      await _auth.currentUser.reauthenticateWithCredential(credential);
      // await _auth.signOut();
      await _auth.currentUser.delete();
      return "success";
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.code;
    }
  }
  Future<String> editAccount({String password, Map changes}) async{
    try{
      EmailAuthCredential credential = EmailAuthProvider.credential(email: currentUser.email, password: password);
      await _auth.currentUser.reauthenticateWithCredential(credential);

      if(changes['password']!=null) await _auth.currentUser.updatePassword(changes['password']);
      if(changes['email']!=null) await _auth.currentUser.updateEmail(changes['email']);
      if(changes['username']!=null) await _auth.currentUser.updateProfile(displayName:changes['username']);

      return "success";
    }
    on FirebaseAuthException catch(e){
      print(e.code);
      return e.code;
    }
  }
}