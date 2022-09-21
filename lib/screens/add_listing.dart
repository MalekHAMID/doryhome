import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doryhome/data.dart';
import 'package:doryhome/partition%20screens/hostel_add.dart';
import 'package:doryhome/partition%20screens/tourstic_apartment.dart';
import 'package:doryhome/screens/verification_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddListing extends StatefulWidget {
  AddListing({Key? key}) : super(key: key);

  @override
  State<AddListing> createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  int initialIndex = 0;
  final _phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: users.doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.data!.get('phone') == null) {
              return Scaffold(
                body: Form(
                  key: _formKey,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7.5),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                spreadRadius: 2)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _phone,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.characters.length != 10 ||
                                  value.characters.first != "5") {
                                return "Please Enter your Turkish Phone Number";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              label: const Text(
                                  "Please Enter phone number to be able to publish"),
                              helperText: "53x xxx xx xx",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.black26),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await users.doc(snapshot.data!.id).set({
                                  "phone": _phone.text,
                                }, SetOptions(merge: true));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Please fill the blank fields"),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.all(15),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.shade400,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                "Update",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (!snapshot.data!.get("isAdmin")) {
              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      child: Image.asset('assets/doryhome.png'),
                    ),
                    AlertDialog(
                      title: Text(
                        "You Have No Authorization To Publish Listings",
                        style: GoogleFonts.josefinSans(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        "Please Navigate to this page if you want to be able to publish listings",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.josefinSans(color: Colors.black54),
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          VerificationRequest()));
                            },
                            child: Text(
                              "BECOME A PUBLISHER",
                              textAlign: TextAlign.center,
                              style:
                                  GoogleFonts.josefinSans(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size(double.infinity, 60),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(15),
                    child: ToggleSwitch(
                      initialLabelIndex: initialIndex,
                      onToggle: (index) {
                        setState(() {
                          initialIndex = index!;
                        });
                      },
                      labels: const ['Hostels', 'Touristic Apartments'],
                      totalSwitches: 2,
                      minWidth: 190,
                      activeBgColor: [Colors.redAccent.shade400],
                      inactiveBgColor: Colors.white,
                    ),
                  ),
                ),
                body: initialIndex == 0 ? AddHostel() : ApartmentAdd(),
              );
            }
          }
        });
  }
}
