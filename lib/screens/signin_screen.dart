import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:a/reusable_widgets/reusable_widgets.dart';
import 'package:a/screens/homescreen.dart';
import 'package:a/screens/signup_screen.dart';



// SignInScreen is a stateful widget that handles user sign-in
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

//intializing password and email to sign in
class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();


// Function to show a SnackBar with a given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
//making restrictions on the email
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }
//handle the sign in process
  void _handleSignIn() {
    final email = _emailTextController.text.trim();
    final password = _passwordTextController.text.trim();
//checking the email format
    if (!_isValidEmail(email)) {
      _showSnackBar("Invalid email format");
      return;
    }
//using firebase auth package to make sure that the email and password are correct and saved in the database
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }).onError((error, stackTrace) {
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          _showSnackBar("No user found for that email");
        } else if (error.code == 'wrong-password') {
          _showSnackBar("Incorrect password");
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
                reusableTextField("Enter email", Icons.email_outlined, false, _emailTextController),
                SizedBox(height: 20),
                reusableTextField("Enter password", Icons.lock_outline, false, _passwordTextController),
                SigninSignupButton(context, true, _handleSignIn),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }
//creating this to add the signup option if you don't have account
  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            "Sign up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}