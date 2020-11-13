import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Profile.dart';



class CustomAvatar extends StatelessWidget {
  @required final String imgURL;
  @required final StorageController source;
  String initials;
  double radius;

  CustomAvatar({this.imgURL, this.source, this.initials = '', this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return (imgURL != null)?
    FutureBuilder(
      future: source.getImgURL(imgURL),
      builder: (context, url) {
        if (url.hasError) {
          return CircleAvatar(backgroundImage: NetworkImage("https://www.lewesac.co.uk/wp-content/uploads/2017/12/default-avatar.jpg"), radius: radius);
        } else if (url.hasData) {
          return CircleAvatar(backgroundImage: NetworkImage(url.data), radius: radius);
        } else {
          return SizedBox(width: radius*2, height: radius*2, child: CircularProgressIndicator());
        }
      },
    ) :
    CircleAvatar(
      child: Text(this.initials, style: TextStyle(fontSize: radius),),
      backgroundColor: Theme.of(context).primaryColorLight,
      radius: radius,
    );
  }
}

class ProfileOccupationDisplay extends StatelessWidget {
  @required final Profile profile;

  ProfileOccupationDisplay({this.profile});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.name, style: Theme.of(context).textTheme.headline6,),
            if (profile.occupation != null) ...[
              SizedBox(height: 8.0,),
              Text(profile.occupation),
            ],
          ],
        ),
      ),
    );
  }
}

class AvatarWithBorder extends StatelessWidget {
  String imgURL;
  double radius, border;
  Icon icon;
  Color borderColor, backgroundColor;
  StorageController source;

  AvatarWithBorder({this.imgURL, this.radius = 20, this.border = 5, this.icon, this.backgroundColor, this.borderColor, this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              spreadRadius: 2,
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 10)
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: this.borderColor,
        radius: this.radius,
        child: (this.imgURL != null && this.source != null)? CustomAvatar(
            imgURL: this.imgURL,
            radius: this.radius - this.border,
            source: this.source,
        ) : CircleAvatar(
          radius: this.radius - this.border,
          backgroundColor: this.backgroundColor,
          child: (this.icon != null)? this.icon : Icon(Icons.error),
        ),
      ),
    );
  }
}

// with love, from https://github.com/ponnamkarthik/MultiSelectChoiceChip/blob/master/lib/main.dart
class MultiSelectChip extends StatefulWidget {
  final List<String> list;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.list, {this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  // String selectedChoice = "";
  List<String> selectedChoices = List();

  _buildChoiceList() {
    List<Widget> choices = List();

    widget.list.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

class InterestsWrap extends StatelessWidget{
  @required final List<String> interests;

  InterestsWrap(this.interests);
  @override
  Widget build(BuildContext context) {
    List<Widget> chips = List();
    if(interests != null) {
      interests.forEach((element) {
        chips.add(Container(
          padding: const EdgeInsets.all(2.0),
          child: Chip(
            label: Text(element),
          ),
        ));
      });
    }
    return Wrap(children: chips);
  }

}

class TextFieldWidget extends StatefulWidget{
  final String labelText;
  final String placeholder;
  final TextEditingController controller;
  final bool isValid;
  final bool hint;
  TextFieldWidget(this.labelText, this.placeholder, this.controller, this.isValid, this.hint);
  @override
  _TextFieldState createState() => _TextFieldState();


}

class _TextFieldState extends State<TextFieldWidget>{
  FontWeight weight;
  @override
  Widget build(BuildContext context) {
    if(widget.hint) weight=FontWeight.w100;
    else  weight=FontWeight.w400;
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0, left: 10.0, right: 10.0),
      child: TextField(
        controller: widget.controller,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: widget.labelText,
          labelStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: widget.placeholder,
          hintStyle: TextStyle(
            fontSize: 18,
            fontWeight: weight,
            color: Colors.black,
          ),
          errorText: widget.isValid ? null : "Invalid Information",
        ),
      ),
    );
  }
}




