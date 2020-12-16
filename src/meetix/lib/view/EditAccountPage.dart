import 'package:meetix/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

class EditAccountPage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;

  EditAccountPage(this._firestore, this._storage,  this._functions);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {


  _EditAccountPageState();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _currentpasswordController = TextEditingController();
  TextEditingController _newpasswordController = TextEditingController();

  bool _usernameValid = true;
  bool _emailValid = true;
  bool _currentpasswordValid = true;
  bool _newpasswordValid = true;

  updateValid(cond) {
    setState(() {
      _currentpasswordValid = cond;
    });
  }

   submitForm() async{
      setState(() {
        _emailController.text = _emailController.text.trim();
        _emailValid = _emailController.text.isEmpty || RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text);
        _usernameController.text = _usernameController.text.trim();
        _usernameValid = _usernameController.text.isEmpty || RegExp("[a-zA-Z0-9]{3,}").hasMatch(_usernameController.text);
        _currentpasswordValid = _currentpasswordController.text.isNotEmpty;
      });
      if(_emailValid && _usernameValid &&_currentpasswordValid && _newpasswordValid){
        Map updates = Map<String,dynamic>();
        if(_emailController.text.isNotEmpty && _emailController.text != context.read<AuthController>().currentUser.email)
          updates['email'] = _emailController.text;
        if(_usernameController.text.isNotEmpty && _usernameController.text != context.read<AuthController>().currentUser.displayName)
          updates['username'] = _usernameController.text;
        if(_newpasswordController.text.isNotEmpty)
          updates['password'] = _newpasswordController.text;

        print(updates);
        String code = await context.read<AuthController>().editAccount(password:_currentpasswordController.text,changes:updates);

        if (code == 'wrong-password')
          setState(() {
            _currentpasswordValid = false;
          });
        if(code == 'invalid-display-name'){
          setState(() {
            _usernameValid = false;
          });
        }
        if(code == 'email-already-in-use' || code == 'invalid-email'){
          setState(() {
            _emailValid = false;
          });
        }
        if(code == 'invalid-password' ||code == 'weak-password' ){
          setState(() {
            _newpasswordValid = false;
          });
        }
        if (code == 'success')
          Navigator.pop(context,true);
      }

   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit your account")),
      body: _buildBody(context),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.grey),)
              ),
              SizedBox(width: 20,),
              RaisedButton(
                onPressed: (){submitForm();},
                child: Text("Save changes", style: TextStyle(color: Colors.white),), color: Color.fromRGBO(255, 153, 102, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildBody(BuildContext context) {

  return Container(
    child: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: 30,),
          TextFieldWidget(
            labelText: "Username",
            hintText: context.watch<AuthController>().currentUser.displayName,
            hintWeight: FontWeight.w400,
            controller: _usernameController,
            isValid: _usernameValid,
            defaultValue: context.watch<AuthController>().currentUser.displayName,
            errorText: "Must be at least 3 characters/numbers, no symbols",
          ),
          TextFieldWidget(
            labelText: "Email",
            hintText: context.watch<AuthController>().currentUser.email,
            hintWeight: FontWeight.w400,
            controller: _emailController,
            textInputType: TextInputType.emailAddress,
            isValid: _emailValid,
            defaultValue: context.watch<AuthController>().currentUser.email,
            errorText: "Must be a valid email and not used by another account",
          ),
          TextFieldWidget(
            labelText: "Current Password",
            hintWeight: FontWeight.w400,
            controller: _currentpasswordController,
            textInputType: TextInputType.visiblePassword,
            isValid: _currentpasswordValid,
            obscure: true,
            errorText: "Wrong password",
          ),
          TextFieldWidget(
            labelText: "New Password",
            hintWeight: FontWeight.w400,
            controller: _newpasswordController,
            textInputType: TextInputType.visiblePassword,
            isValid: _newpasswordValid,
            obscure: true,
            errorText: "Invalid password, password must be at least 6 characters",
          ),
          Text("Edit the fields you want to change.\nYou must always input your current password", textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height:30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RaisedButton(
                color: Color.fromRGBO(179, 0, 0, 1.0),
                child: Container(
                  child: Row(
                    mainAxisSize:MainAxisSize.min,

                    children:[
                      Icon(Icons.delete_forever, color: Colors.white,),
                      Text("Delete account", style:TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                onPressed: (){showDialog(context: context, child: DeleteAccountDialog(),);},
            ),
          )
        ],
      ),
    ),
  );

  }

}


