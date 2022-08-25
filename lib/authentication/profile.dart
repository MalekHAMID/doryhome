import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doryhome/data.dart';
import 'package:doryhome/partition%20screens/show_hostels.dart';
import 'package:doryhome/partition%20screens/show_tourstic_apartments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int initialIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Container(),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: users.doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        height: 60,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data!.get('image'),
                        ),
                      ),
                      Text(
                        snapshot.data!.get('username'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  endIndent: 50,
                  indent: 50,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  child: ToggleSwitch(
                    initialLabelIndex: initialIndex,
                    onToggle: (index) {
                      setState(() {
                        initialIndex = index!;
                      });
                    },
                    minWidth: 190,
                    labels: const ['Hostels', 'Touristic Apartments'],
                    totalSwitches: 2,
                    activeBgColor: [Colors.redAccent.shade400],
                    inactiveBgColor: Colors.white,
                  ),
                ),
                initialIndex == 0
                    ? Expanded(
                        child: ShowHostel(
                            id: FirebaseAuth.instance.currentUser!.uid))
                    : Expanded(child: ShowApartments()),
              ],
            );
          }
        },
      ),
    );
  }
}
