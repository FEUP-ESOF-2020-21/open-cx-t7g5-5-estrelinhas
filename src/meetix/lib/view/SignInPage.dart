import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferenceListPage.dart';
import 'package:meetix/view/SignUpPage.dart';
import 'package:provider/provider.dart';


class SignInPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;

  SignInPage(this._firestore, this._storage);

  @override
  State<StatefulWidget> createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (context.watch<User>() != null) {
      return ConferenceListPage(widget._firestore, widget._storage);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sign In"),),
      body: _signInForm(),
    );
  }

  Widget _signInForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Email"
          ),
        ),
        TextField(
          controller: _passwordController,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: "Password",
          ),
          obscureText: true,
        ),
        RaisedButton(
          onPressed: (){
            context.read<AuthController>().signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim()
            );
          },
          child: Text("Sign In"),
        ),
        RaisedButton(
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage(widget._firestore, widget._storage)));
          },
          child: Text("Sign Up"),
        )
      ],
    );
  }
}