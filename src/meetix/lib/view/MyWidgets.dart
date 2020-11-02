import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetix/controller/StorageController.dart';
import 'package:meetix/model/Profile.dart';

class CustomAvatar extends StatelessWidget {
  @required final String imgURL;
  @required final StorageController source;
  String initials;
  double radius = 20;

  CustomAvatar({this.imgURL, this.source, this.initials, this.radius});

  @override
  Widget build(BuildContext context) {
    return (imgURL != null)?
    FutureBuilder(
      future: source.getImgURL(imgURL),
      builder: (context, url) {
        if (url.hasError) {
          return Icon(Icons.error);
        } else if (url.hasData) {
          return CircleAvatar(backgroundImage: NetworkImage(url.data), radius: radius,);
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

class NameOrgDisplay extends StatelessWidget {
  @required final Profile profile;

  NameOrgDisplay({this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(profile.name, style: Theme.of(context).textTheme.headline6,),
        if (profile.organization != null) ...[
          SizedBox(height: 8.0,),
          Text(profile.organization),
        ],
      ],
    );
  }


}