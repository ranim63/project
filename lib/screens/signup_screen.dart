import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:a/reusable_widgets/reusable_widgets.dart';
import 'package:a/screens/homescreen.dart';
//create a class to create account on the app
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
//taking the email,username and password 
class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
//validating the formate of the email 
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  void _handleSignUp() {
    final email = _emailTextController.text.trim();
    final password = _passwordTextController.text.trim();

    if (!_isValidEmail(email)) {
      _showSnackBar("Invalid email format");
      return;
    }

    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) {
      print("Created New Account");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      //checking any errors if this email is already used or invalid email format
    }).onError((error, stackTrace) {
      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          _showSnackBar("Email is already in use by another user");
        } else if (error.code == 'invalid-email') {
          _showSnackBar("Invalid email format");
        } else {
          _showSnackBar("Error: ${error.message}");
        }
      } else {
        _showSnackBar("An unexpected error occurred");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromRGBO(254, 254, 253, 0.659),
              const Color.fromARGB(68, 0, 0, 0),
              const Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.08, 50, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.jpeg"),
                SizedBox(height: 20),
                reusableTextField("Enter username", Icons.person_outline, false, _userNameTextController),
                SizedBox(height: 20),
                reusableTextField("Enter email", Icons.email_outlined, false, _emailTextController),
                SizedBox(height: 20),
                reusableTextField("Enter password", Icons.lock_outline, false, _passwordTextController),
                SigninSignupButton(context, false, _handleSignUp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}