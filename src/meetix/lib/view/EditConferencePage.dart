import 'package:flutter/foundation.dart';
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

class EditConferencePage extends StatefulWidget {
  final FirestoreController _firestore;
  final StorageController _storage;
  final FunctionsController _functions;
  final Conference _conference;

  EditConferencePage(this._firestore, this._storage,  this._functions, this._conference);

  @override
  _EditConferencePageState createState() => _EditConferencePageState();
}

class _EditConferencePageState extends State<EditConferencePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _interestsController = TextEditingController();


  bool _nameValid = true;
  bool _startDateValid = true;
  bool _endDateValid = true;
  bool _interestsValid = true;
  String profileImgPath;

  Map updates = Map<String,dynamic>();

  @override
  initState(){
    super.initState();

    profileImgPath = widget._conference.img;
  }

  submitForm() {
    setState(() {
      (_nameController.text.isEmpty || _nameController.text.length >= 3)? _nameValid = true : _nameValid = false;
      (_startDateController.text.isEmpty || _startDateController.text.length <= 10)? _startDateValid = true : _startDateValid = false;
      (_endDateController.text.isEmpty || _endDateController.text.length <= 10 || _compareDates(_endDateController.text, _startDateController.text))? _endDateValid = true : _endDateValid = false;
      (_interestsController.text.isEmpty)? _interestsValid = true : _interestsValid = false;
    });

    if (_nameValid && _startDateValid && _endDateValid && _interestsValid) {
      if(_nameController.text.isNotEmpty)
        updates['name'] = _nameController.text;
      if(_startDateController.text.isNotEmpty)
        updates['start_date'] = _startDateController.text;
      if(_endDateController.text.isNotEmpty)
        updates['end_date'] = _endDateController.text;
      if(_interestsController.text.isNotEmpty)
        updates['interests'] = _interestsController.text.split(",");

      widget._conference.reference.update(updates);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Conference")),
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
                child: Text("Save changes", style: TextStyle(color: Colors.white),), color: Theme.of(context).accentColor,
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
              hintText: widget._conference.name,
              hintWeight: FontWeight.w400,
              controller: _nameController,
              isValid: _nameValid,
            ),
            SizedBox(height: 10),
            TextFieldWidget(
              labelText: "Start Date",
              hintText: widget._conference.start_date,
              hintWeight: FontWeight.w400,
              controller: _startDateController,
              isValid: _startDateValid,
            ),
            SizedBox(height: 10),
            TextFieldWidget(
              labelText: "End Date",
              hintText: widget._conference.end_date,
              hintWeight: FontWeight.w400,
              controller: _endDateController,
              isValid: _endDateValid,
            ),
            SizedBox(height: 10),
            TextFieldWidget(
              labelText: "Interests",
              hintText: widget._conference.interests.join(','),
              hintWeight: FontWeight.w400,
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
        return d1Day >= d2Day;
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


