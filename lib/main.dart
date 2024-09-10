import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:a/screens/signin_screen.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 215, 57, 215)),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      //when logged in navigate to signin screen
      home: const SignInScreen(),
    );
  }
}