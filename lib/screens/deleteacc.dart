import 'package:a/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:a/reusable_widgets/reusable_widgets.dart';//import the important packages that will be used 

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleDeleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
//use a function from firebase.auth to delete the account
      if (user != null) {
        await user.delete();

        //show to the user that the account is deleted 
        _showSnackBar("Account deleted successfully");
        Navigator.pushReplacement(
          context,
          //if the account is deleted go to the sign in page
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } else {
        _showSnackBar("No user is currently signed in");
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        _showSnackBar("Please re-authenticate and try again");
      } else {
        _showSnackBar("Error: ${error.message}");
      }
    } catch (e) {
      _showSnackBar("An unexpected error occurred");
    }
  }
// This widget builds the main screen of the delete account screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Delete Account",
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
                ElevatedButton(
                  onPressed: _handleDeleteAccount,
                  child: Text("confirm deleting this account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
