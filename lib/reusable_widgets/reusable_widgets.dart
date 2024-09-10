import 'package:flutter/material.dart';
// this is used to just call these functions if i will use them more than time 
Image logoWidget(String imageName){
    return Image.asset(imageName,
    fit:BoxFit.fitHeight,width:350,
    height: 240);
  }//the text field as we will use it to take the password and email in the signin and signup pages
  TextField reusableTextField(String text,IconData icon,bool isPasswordType,
  TextEditingController controller){
    return TextField(
controller: controller,
obscureText: isPasswordType,
enableSuggestions: !isPasswordType,
autocorrect: !isPasswordType,
cursorColor: Colors.white,
style: TextStyle(color:Colors.white.withOpacity(0.9) ),
decoration: InputDecoration(
  prefixIcon: Icon(icon,
  color: Colors.white70,),
  labelText: text,
  labelStyle: TextStyle(color:Colors.white.withOpacity(0.9)),
  filled: true,
  floatingLabelBehavior: FloatingLabelBehavior.never,
  fillColor: Colors.white.withOpacity(0.3),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(30.0),
    borderSide: const BorderSide(width: 0,style: BorderStyle.none)
  )

),keyboardType: isPasswordType?TextInputType.visiblePassword:TextInputType.emailAddress,
    );
    

  }
  //creating a button for sign in and sign up instead of creating two buttons
  // by checking the conditions of signed in or not if not make it signup
  Container SigninSignupButton(BuildContext context,bool islogin,Function onTap

  ){
    return Container(

  height: 50.0,
  width: MediaQuery.of(context).size.width * 0.9,
  margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(90),
  ),
  child: ElevatedButton(
    onPressed: () {
     onTap();
    },
    child: Text(
      islogin? 'LOGIN':'SIGN UP',
      style: const TextStyle(
        color: Colors.black87,
        fontFamily: 'Avenir',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.pressed)){
            return Colors.black26;}
            return Colors.white;
        },
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20))))
  ),
);
  }