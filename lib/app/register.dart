import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:flutter/material.dart';

import 'package:halwa/app/app.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool _obscureText = true;

  double _letterSpacing = 2.0;

  XFile? imageXFile;
  CroppedFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageXFile != null) {
      imageFile = await ImageCropper().cropImage(
        sourcePath: imageXFile!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Profile Photo",
            toolbarColor: Color(0xFFE85852),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          )
        ],
      );
    }
    setState(() {});
  }

  IconData _passwordIcon = Icons.visibility;
  List<Widget> registerWidgetList = [
    Text(
      'Register',
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  ];

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final firstNameTextController = TextEditingController();
  final lastNameTextController = TextEditingController();
  String userImageUrl = "";

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
      if (_passwordIcon == Icons.visibility_off) {
        _passwordIcon = Icons.visibility;
        _letterSpacing = 2.0;
      } else {
        _passwordIcon = Icons.visibility_off;
        _letterSpacing = 1.0;
      }
    });
  }

  void validateAndRegister() async {
    if (firstNameTextController.text.isEmpty) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Register Error!"),
              content:
                  Text("Please enter a valid name in the First Name field."),
              actions: <Widget>[],
            );
          });
      return;
    }

    if (lastNameTextController.text.isEmpty) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Register Error!"),
              content:
                  Text("Please enter a valid name in the Last Name field."),
              actions: <Widget>[],
            );
          });
      return;
    }

    if (emailTextController.text.isEmpty) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Register Error!"),
              content: Text("Please enter a valid email in the Email field."),
              actions: <Widget>[],
            );
          });
      return;
    }

    if (passwordTextController.text.isEmpty) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Register Error!"),
              content:
                  Text("Please enter a valid password in the passwrod field."),
              actions: <Widget>[],
            );
          });
      return;
    }

    setState(() {
      registerWidgetList = [
        Text(
          'Register',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(
          child: CircularProgressIndicator(color: Colors.white),
          height: 28.0,
          width: 28.0,
        ),
      ];
    });

    if (imageFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebaseStorage.Reference reference = firebaseStorage
          .FirebaseStorage.instance
          .ref()
          .child("users")
          .child(fileName);
      firebaseStorage.UploadTask uploadTask =
          reference.putFile(File(imageFile!.path));
      firebaseStorage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() {});
      await taskSnapshot.ref.getDownloadURL().then((url) {
        userImageUrl = url;
      });
    }

    User? currentUser;
    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: emailTextController.text.trim(),
      password: passwordTextController.text.trim(),
    )
        .then(
      (auth) {
        currentUser = auth.user!;
      },
    ).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text("Register Error!"),
            content: Text(error.message.toString()),
            actions: <Widget>[],
          );
        },
      );
    });

    if (currentUser == null) {
      showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text("Register Error!"),
            content: Text(
                "Account does not exist. Register to create a new account."),
            actions: <Widget>[],
          );
        },
      );
      return;
    }

    FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).set(
      {
        "uid": currentUser!.uid,
        "email": currentUser!.email,
        "firstName": firstNameTextController.text.trim(),
        "lastName": lastNameTextController.text.trim(),
        "photoUrl": userImageUrl,
        "status": "approved",
        "userCart": [''],
      },
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => App()),
    );

    setState(() {
      registerWidgetList = [
        Text(
          'Register',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  _getImage();
                },
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.30,
                  backgroundColor: Colors.white,
                  backgroundImage: imageFile == null
                      ? null
                      : FileImage(
                          File(imageFile!.path),
                        ),
                  child: imageFile == null
                      ? Icon(
                          Icons.person_add_alt_1,
                          size: MediaQuery.of(context).size.width * 0.30,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 20.0,
                right: 20.0,
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: firstNameTextController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.primaryColor, width: 1.0),
                  ),
                  prefixIcon: Icon(
                    Icons.account_circle,
                    size: 28.0,
                    color: theme.primaryColor,
                  ),
                  hintText: 'First Name',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 19.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 20.0,
                right: 20.0,
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: lastNameTextController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.primaryColor, width: 1.0),
                  ),
                  prefixIcon: Icon(
                    Icons.account_circle,
                    size: 28.0,
                    color: theme.primaryColor,
                  ),
                  hintText: 'Last Name',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 19.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 20.0,
                right: 20.0,
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: emailTextController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.primaryColor, width: 1.0),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: 28.0,
                    color: theme.primaryColor,
                  ),
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 19.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 20.0,
                right: 20.0,
              ),
              child: TextField(
                obscureText: _obscureText,
                style: TextStyle(letterSpacing: _letterSpacing),
                keyboardType: TextInputType.text,
                autocorrect: false,
                controller: passwordTextController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: theme.primaryColor, width: 1.0),
                  ),
                  prefixIcon: Icon(
                    Icons.key,
                    size: 28.0,
                    color: theme.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordIcon,
                      size: 28.0,
                      color: theme.primaryColor,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  hintText: 'Password',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 19.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 25.0,
                left: 20.0,
                right: 20.0,
              ),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(const Size(50, 50)),
                  backgroundColor:
                      MaterialStateProperty.all(theme.primaryColor),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: registerWidgetList,
                  ),
                ),
                onPressed: () {
                  validateAndRegister();
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}
