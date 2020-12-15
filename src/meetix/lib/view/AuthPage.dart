import 'package:flutter/cupertino.dart';
import 'SignInPage.dart';
import 'SignUpPage.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _signUp = true;

  void switchPage() {
    setState(() {
      _signUp = !_signUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_signUp) {
      return SignUpPage(onSwitch: switchPage,);
    } else {
      return SignInPage(onSwitch: switchPage,);
    }
  }
}