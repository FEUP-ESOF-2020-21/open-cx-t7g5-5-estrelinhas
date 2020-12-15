import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onSwitch;

  SignUpPage({@required this.onSwitch});

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
              OutlineButton(
                onPressed: widget.onSwitch,
                child: Text("Sign In"),
              ),
              SizedBox(width: 60.0,),
              SignUpButton(email: _emailController, password: _passwordController, displayName: _nameController,),
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
      color: Color.fromRGBO(255, 153, 102, 1),
    );
  }
}