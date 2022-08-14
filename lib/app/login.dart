import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:halwa/app/app.dart';
import 'package:halwa/app/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool _obscureText = true;

  double _letterSpacing = 2.0;

  IconData _passwordIcon = Icons.visibility;
  List<Widget> loginWidgetList = [
    Text(
      'Log In',
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  ];

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

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

  void validateAndLogin() async {
    if (emailTextController.text.isEmpty) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Login Error!"),
              content: Text("Please enter a valid email in the email field."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(1),
                  child: const Text(
                    "Okay",
                    style: TextStyle(
                      fontSize: 19.0,
                      color: Color(0xFFE85852),
                    ),
                  ),
                ),
              ],
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
              title: Text("Login Error!"),
              content:
                  Text("Please enter a valid password in the passwrod field."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(1),
                  child: const Text(
                    "Okay",
                    style: TextStyle(
                      fontSize: 19.0,
                      color: Color(0xFFE85852),
                    ),
                  ),
                ),
              ],
            );
          });
      return;
    }

    setState(() {
      loginWidgetList = [
        Text(
          'Log In',
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

    User? currentUser;
    await firebaseAuth
        .signInWithEmailAndPassword(
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
            title: Text("Login Error!"),
            content: Text(error.message.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(1),
                child: const Text(
                  "Okay",
                  style: TextStyle(
                    fontSize: 19.0,
                    color: Color(0xFFE85852),
                  ),
                ),
              ),
            ],
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
            title: Text("Login Error!"),
            content: Text(
                "Account does not exist. Register to create a new account."),
            actions: <Widget>[],
          );
        },
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => App()),
    );

    setState(() {
      loginWidgetList = [
        Text(
          'Log In',
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/logo_name.png'),
                          fit: BoxFit.contain,
                        ),
                        shape: BoxShape.rectangle,
                      ),
                    )
                  ],
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
                      minimumSize:
                          MaterialStateProperty.all(const Size(50, 50)),
                      backgroundColor:
                          MaterialStateProperty.all(theme.primaryColor),
                      shadowColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: loginWidgetList,
                      ),
                    ),
                    onPressed: () {
                      validateAndLogin();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                            TextSpan(
                              text: 'Register',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Register()));
                                },
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
