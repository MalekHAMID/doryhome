import 'package:doryhome/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../authentication/login_screen.dart';

class WaitingScreen extends StatefulWidget {
  WaitingScreen({Key? key}) : super(key: key);

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 3), () {
          auth.authStateChanges().listen((event) {
            if (event == null) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            }
          });
        }),
        builder: (context, time) {
          return Column(
            children: [
              LottieBuilder.asset("assets/home.json"),
              const SizedBox(
                height: 25,
              ),
              CircularProgressIndicator.adaptive(
                backgroundColor: Colors.redAccent.shade400,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}
