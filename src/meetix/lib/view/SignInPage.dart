import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback onSwitch;

  SignInPage({@required this.onSwitch}): super(key: Key("SignInPage"));

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            key: Key("emailField"),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email"
            ),
          ),
          TextField(
            key: Key("passwordField"),
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: "Password",
            ),
            obscureText: true,
          ),
          SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlineButton(
                onPressed: widget.onSwitch,
                child: Text("Sign Up"),
              ),
              SizedBox(width: 60.0),
              SignInButton(email: _emailController, password: _passwordController,),
            ],
          ),
        ],
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  final TextEditingController email, password;

  SignInButton({this.email, this.password});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      key: Key("signInButton"),
      onPressed: (){
        context.read<AuthController>().signIn(
            email: email.text.trim(),
            password: password.text.trim()
        ).then((value) { Scaffold.of(context).removeCurrentSnackBar(reason: SnackBarClosedReason.remove); Scaffold.of(context).showSnackBar(SnackBar(content: Text(value))); } );
      },
      child: Text("Sign In", style: TextStyle(color: Colors.white),),
      color: Theme.of(context).accentColor,
    );
  }
}