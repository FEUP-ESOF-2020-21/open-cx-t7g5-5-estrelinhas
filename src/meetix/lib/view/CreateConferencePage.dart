import 'package:meetix/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/ConferenceListPage.dart';
import 'package:meetix/view/ConferencePage.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

import '../model/Conference.dart';
import '../controller/FirestoreController.dart';

class CreateConferencePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;

  CreateConferencePage(this._firestore, this._storage,  this._functions);

  @override
  _CreateConferencePageState createState() => _CreateConferencePageState();
}

class _CreateConferencePageState extends State<CreateConferencePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _interestsController = TextEditingController();

  bool _nameValid = true;
  bool _startDateValid = true;
  bool _endDateValid = true;
  bool _interestsValid = true;
  String profileImgPath = 'default-avatar.jpg';

  submitForm() {
    setState(() {
      (_nameController.text.isEmpty || _nameController.text.length < 3)? _nameValid = false : _nameValid = true;
      (_startDateController.text.isEmpty || _startDateController.text.length < 10)? _startDateValid = false : _startDateValid = true;
      (_endDateController.text.isEmpty || _endDateController.text.length < 10 || !_compareDates(_endDateController.text, _startDateController.text))? _endDateValid = false : _endDateValid = true;
      (_interestsController.text.isEmpty)? _interestsValid = false : _interestsValid = true;

      if (_nameValid && _startDateValid && _endDateValid && _interestsValid) {
        widget._firestore.getConferenceCollection().doc(_nameController.text).set({'uid':context.read<AuthController>().currentUser.uid,
                                                                  'name':_nameController.text,
                                                                  'img':profileImgPath,
                                                                  'interests': _interestsController.text.split(","),
                                                                  'start_date':_startDateController.text,
                                                                  'end_date': _endDateController.text

        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConferenceListPage(widget._firestore, widget._storage, widget._functions)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Conference")),
      body: _buildBody(context),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 20,),
              RaisedButton(
                onPressed: (){submitForm();},
                child: Text("Create", style: TextStyle(color: Colors.white),), color: Theme.of(context).accentColor,
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
          children: [
            SizedBox(height: 50),

            TextFieldWidget(
              labelText: "Name",
              hintText: "Conference Name",
              controller: _nameController,
              isValid: _nameValid,
            ),
            SizedBox(height: 10),
            TextFieldWidget(
              labelText: "Start Date",
              hintText: "dd/mm/yyyy",
              controller: _startDateController,
              isValid: _startDateValid,
            ),
            SizedBox(height: 10),
            TextFieldWidget(
              labelText: "End Date",
              hintText: "dd/mm/yyyy",
              controller: _endDateController,
              isValid: _endDateValid,
            ),
            SizedBox(height: 10),
            TextFieldWidget(
                labelText: "Interests",
                hintText: "AI,media,...",
                controller: _interestsController,
                isValid: _interestsValid,
            ),
          ],
        ),
      ),
    );
  }

  bool _compareDates(String d1, String d2) {
    int d1Day = int.parse(d1.substring(0,2));
    int d1Month = int.parse(d1.substring(3,5));
    int d1Year = int.parse(d1.substring(6));
    int d2Day = int.parse(d2.substring(0,2));
    int d2Month = int.parse(d2.substring(3,5));
    int d2Year = int.parse(d2.substring(6));

    if(d1Year == d2Year){
      if(d1Month == d2Month){
        return d1Day > d2Day;
      }
      else{
        return d1Month > d2Month;
      }
    }
    else{
      return d1Year > d2Year;
    }
  }
}


