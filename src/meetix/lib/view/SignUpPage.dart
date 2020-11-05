import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/SignInPage.dart';
import 'package:provider/provider.dart';

import 'ConferenceListPage.dart';


class SignUpPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;

  SignUpPage(this._firestore, this._storage);

  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (context.watch<User>() != null) {
      return ConferenceListPage(widget._firestore, widget._storage);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sign Up for Meetix"),),
      body: _signUpForm(),
    );
  }

  Widget _signUpForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
                labelText: "Name"
            ),
          ),
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
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignUpButton(email: _emailController, password: _passwordController, displayName: _nameController,),
              SizedBox(width: 60.0,),
              RaisedButton(
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage(widget._firestore, widget._storage)));
                },
                child: Text("Sign In"),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  final TextEditingController email, password, displayName;

  SignUpButton({this.email, this.password, this.displayName});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: (){
        context.read<AuthController>().signUp(
          email: email.text.trim(),
          password: password.text.trim(),
          displayName: displayName.text.trim()
        ).then((value) { Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.remove); Scaffold.of(context).showSnackBar(SnackBar(content: Text(value))); } );
      },
      child: Text("Sign Up", style: TextStyle(color: Colors.white),),
      color: Theme.of(context).accentColor,
    );
  }
}