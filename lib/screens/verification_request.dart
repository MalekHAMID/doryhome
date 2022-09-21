import 'package:doryhome/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        centerTitle: true,
      ),
      body: _loading == false
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Please Write Down The Reason For You To Post Listing in Doryhome",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
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
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          )),
                      hintText:
                          "Eg: I am an owner of a hostel / Rented apartment ",
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
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "by pressing send, you are agreeing to be contacted through mail or/and phone number. \n and also agreeing to our terms and fees in case of acceptance. \n",
                                style: TextStyle(color: Colors.black54),
                              ),
                              InkWell(
                                  onTap: () {
                                    launchUrlString(
                                        "https://devlads.net/?page_id=3");
                                  },
                                  child: const Text(
                                    "terms and conditions",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12),
                                  )),
                            ],
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actions: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.redAccent.shade400),
                                ),
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
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Send",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7.5),
                        color: Colors.redAccent.shade400),
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Send Request",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
