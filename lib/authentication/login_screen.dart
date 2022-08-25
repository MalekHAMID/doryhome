import 'package:doryhome/data.dart';
import 'package:doryhome/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
  }

  singinwithgmail() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        // Optional clientId
        // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
        scopes: <String>[
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final user = await FirebaseAuth.instance.signInWithCredential(credential);
      final userexist = await users.doc(user.user!.uid).get();
      if (userexist.exists) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MyHomePage()));
      } else {
        await users.doc(user.user!.uid).set({
          "uid": user.user!.uid,
          "email": user.user!.email,
          "phone": user.user!.phoneNumber,
          "image": user.user!.photoURL,
          "isAdmin": false,
          "isBlocked": false,
          "username": user.user!.displayName,
          "verified_user": false,
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MyHomePage()));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent.shade400,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 120,
            child: Image.asset(
              'assets/doryhome.png',
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              singinwithgmail();
            },
            child: Container(
              // alignment: Alignment.center,
              padding: const EdgeInsets.all(7.5),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7.5),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.start,
                children: [
                  Image.asset(
                    'assets/gmail.png',
                    scale: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Sign in with gmail',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ),
          Container(
            // alignment: Alignment.center,
            padding: const EdgeInsets.all(7.5),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7.5),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.start,
              children: [
                Image.asset(
                  'assets/facebook.png',
                  scale: 25,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Sign in with facebook',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
