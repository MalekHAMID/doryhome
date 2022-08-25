import 'package:doryhome/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VerificationRequest extends StatefulWidget {
  VerificationRequest({Key? key}) : super(key: key);

  @override
  State<VerificationRequest> createState() => _VerificationRequestState();
}

class _VerificationRequestState extends State<VerificationRequest> {
  final _controller = TextEditingController();
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
        title: const Text(
          "Become Verfied",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading == false
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.5),
                      color: Colors.white),
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: 5,
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          )),
                      hintText:
                          "Please summarize the reason for you verfication request",
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Notice",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent.shade400),
                          ),
                          content: const Text(
                            "by pressing send, you are agreeing to be contacted through mail or/and phone number. \n and also agreeing to be charged for the verfication fees in case of acceptance",
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actions: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancel",
                                style:
                                    TextStyle(color: Colors.redAccent.shade400),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  _loading = true;
                                });

                                var docs = await requests
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .get();
                                if (docs.exists) {
                                  setState(() {
                                    _loading = false;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "You have sent a request already!"),
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context);
                                  await requests
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .set(
                                    {
                                      "id": FirebaseAuth
                                          .instance.currentUser!.uid,
                                      "reason": _controller.text,
                                      "date": DateTime.now(),
                                    },
                                  );

                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              },
                              child: const Text(
                                "Send",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7.5),
                        color: Colors.redAccent.shade400),
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      "Send Request",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : LottieBuilder.asset('assets/uploading.json'),
    );
  }
}
