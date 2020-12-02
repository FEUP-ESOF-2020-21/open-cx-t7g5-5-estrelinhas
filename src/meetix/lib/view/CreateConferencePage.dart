import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/MyWidgets.dart';
import 'package:provider/provider.dart';

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
  DateTime _startDate = DateTime.now(), _endDate;
  String profileImgUrl = 'default-conference.png';
  File profileImg;

  submitForm() async {
    setState(() {
      (_nameController.text.isEmpty || _nameController.text.length < 3)? _nameValid = false : _nameValid = true;
      (_startDateController.text.isEmpty)? _startDateValid = false : _startDateValid = true;
      (_endDateController.text.isEmpty)? _endDateValid = false : _endDateValid = true;
      (_interestsController.text.isEmpty)? _interestsValid = false : _interestsValid = true;
    });

    if (_nameValid && _startDateValid && _endDateValid && _interestsValid) {
      DocumentReference docRef = await widget._firestore.getConferenceCollection().add({'uid':context.read<AuthController>().currentUser.uid,
        'name':_nameController.text,
        'img': profileImgUrl,
        'interests': _interestsController.text.split(","),
        'start_date':_startDateController.text,
        'end_date': _endDateController.text
      });

      if(profileImg != null){
        profileImgUrl = 'conferences/' + docRef.id + '/conference_img';
        await widget._storage.uploadFile(profileImgUrl, profileImg);
        Map updates = Map<String,dynamic>();
        updates['img'] = profileImgUrl;
        await docRef.update(updates);
      }
      Navigator.pop(context);
    }
  }

  _selectDate(BuildContext context, TextEditingController destination, bool start) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: (start || _endDate == null)? _startDate : _endDate,
        firstDate: (start)? DateTime.now() : _startDate,
        lastDate: (start && _endDate != null)? _endDate : DateTime(2100)
    );
    if (picked != null)
      setState(() {
        var date = "${picked.toLocal().day}/${picked.toLocal().month}/${picked.toLocal().year}";
        if (start) {
          _startDate = picked;
          _startDateController.text = date;
        }
        else {
          _endDate = picked;
          _endDateController.text = date;
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
            SizedBox(height: 15),
            ShowAvatarEdit(
              storage: widget._storage,
              profileImgUrl: profileImgUrl,
              onFileChosen: (file) {profileImg = file;},
            ),
            SizedBox(height: 35),
            TextFieldWidget(
              labelText: "Name",
              hintText: "Conference Name",
              controller: _nameController,
              isValid: _nameValid,
            ),
            SizedBox(height: 10),
            _dateSelector(context, true),
            SizedBox(height: 10),
            _dateSelector(context, false),
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
      if(d1Month >= d2Month){
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

  Widget _dateSelector(BuildContext context, bool start) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _selectDate(context, _startDateController, start);
      },
      child: Container(
        color: Colors.transparent,
        child: IgnorePointer(
          child: TextFieldWidget(
            labelText: (start)? "Start Date" : "End Date",
            hintText: "Select date",
            controller: (start)? _startDateController : _endDateController,
            isValid: (start)? _startDateValid : _endDateValid,
          ),
        ),
      ),
    );
  }
}


