import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sumate_mobile_app/services/analytics.dart';
import 'package:sumate_mobile_app/services/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sumate_mobile_app/utils/color.dart';
import 'package:sumate_mobile_app/utils/styles.dart';
import 'package:sumate_mobile_app/classes/classes.dart';
import 'package:sumate_mobile_app/classes/models.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class createPostView extends StatefulWidget {
  const createPostView({Key, key, required this.analytics, required this.observer}) : super(key: key);
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _createPostViewState createState() => _createPostViewState();
}
class _createPostViewState extends State<createPostView> {

  bool _checkBoxState = false;
  File? _image = null;
  final picker = ImagePicker();
  late String pickedFileString;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    pickedFileString = pickedFile!.path;
    pickedFileString = pickedFileString.split('/')[pickedFileString.split('/').length - 1];

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _checkBoxState=true;
      } else {
        print('No image selected.');
      }
    });
  }


  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

  @override
  void initState() {
    super.initState();
    enableCrashlytics();
    setCurrentScreen(widget.analytics, widget.observer, 'createPostView', 'createPostViewState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(),
            Text(
              'Create a New Post',
              //style: mainTitleTextStyle,
            ),
            IconButton(
              onPressed: () { Navigator.pushNamed(context, '/creatingPost', arguments: {"image": _image, "filename": pickedFileString}); },
              splashRadius: 30,
              icon: Icon(
                IconData(0xe1f5, fontFamily: 'MaterialIcons'),
                color: _checkBoxState ? Colors.lightGreenAccent: Colors.grey,
              ),
              iconSize: 45,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0.0,
      ),

      body: Center(
        child: _image == null ? Text('No image selected.') : Image.file(_image!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}