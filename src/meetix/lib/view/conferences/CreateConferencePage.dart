import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetix/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/FirestoreController.dart';
import 'package:meetix/controller/FunctionsController.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/view/meetix_widgets/MyWidgets.dart';
import 'package:provider/provider.dart';


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

  String _readableDate(DateTime date) {
    DateTime local = date.toLocal();
    return "${local.day}/${local.month}/${local.year}";
  }

  submitForm() async {
    setState(() {
      _nameController.text = _nameController.text.trim();
      _startDateController.text = _startDateController.text.trim();
      _endDateController.text = _endDateController.text.trim();
      _interestsController.text = _interestsController.text.trim();
      _endDate = _endDate.add(Duration(hours: 23, minutes: 59, seconds: 59));

      _nameValid = _nameController.text.isNotEmpty && _nameController.text.length >= 3;
      _startDateValid = _startDateController.text.isNotEmpty && _startDate.isBefore(_endDate);
      _endDateValid = _endDateController.text.isNotEmpty && _endDate.isAfter(_startDate);
      _interestsValid = _interestsController.text.isNotEmpty;
    });

    if (_nameValid && _startDateValid && _endDateValid && _interestsValid) {
      DocumentReference docRef = await widget._firestore.getConferenceCollection().add({'uid':context.read<AuthController>().currentUser.uid,
        'name':_nameController.text,
        'img': profileImgUrl,
        'interests': _interestsController.text.split(",").map((e) => e.trim()).toSet().where((e) => e.isNotEmpty).toList(),
        'start_date': Timestamp.fromDate(_startDate),
        'end_date': Timestamp.fromDate(_endDate),
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
                child: Text("Create", style: TextStyle(color: Colors.white),), color: Color.fromRGBO(255, 153, 102, 1),
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
              errorText: "Name must be at least 3 characters long",
            ),
            SizedBox(height: 10),
            _dateSelector(context, true),
            SizedBox(height: 10),
            _dateSelector(context, false),
            SizedBox(height: 10),
            TextFieldWidget(
              labelText: "Interests",
              hintText: "AI, media, ... (separated by , )",
              controller: _interestsController,
              isValid: _interestsValid,
              errorText: "You must add at least one interest",
            ),
          ],
        ),
      ),
    );
  }

  _selectDate(BuildContext context, TextEditingController destination, bool start) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: (start || _endDate == null)? _startDate : _endDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        helpText: (start)? "Select start date" : "Select end date",
    );
    if (picked != null)
      setState(() {
        var date = _readableDate(picked);
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
            errorText: (start)? "Start date must be before end date" : "End date must be after start date",
          ),
        ),
      ),
    );
  }
}
