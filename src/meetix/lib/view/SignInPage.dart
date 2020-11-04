import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:provider/provider.dart';


class SignInPage extends StatefulWidget {
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
          decoration: InputDecoration(
            labelText: "Email"
          ),
        ),
        TextField(
          controller: _passwordController,
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
        )
      ],
    );
  }

}