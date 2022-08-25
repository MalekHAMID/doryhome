import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doryhome/authentication/login_screen.dart';
import 'package:doryhome/authentication/profile.dart';
import 'package:doryhome/data.dart';
import 'package:doryhome/screens/add_listing.dart';
import 'package:doryhome/screens/show_listing.dart';
import 'package:doryhome/screens/verification_request.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  List<Widget> pages = [
    ShowListings(),
    AddListing(),
    Profile(),
  ];
  final _advancedDrawerController = AdvancedDrawerController();
  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.red.shade800,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      // openScale: 1.0,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        // NOTICE: Uncomment if you want to add shadow behind the page.
        // Keep in mind that it may cause animation jerks.
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 0.0,
        //   ),
        // ],
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      drawer: Drawer(
        backgroundColor: Colors.red.shade800,
        child: StreamBuilder<DocumentSnapshot>(
            stream:
                users.doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                return ListView(
                  children: [
                    DrawerHeader(
                      child: Container(
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              imageUrl: snapshot.data!.get('image'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              snapshot.data!.get('username'),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        FirebaseAuth.instance.signOut().whenComplete(() =>
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login())));
                      },
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      title: const Text("Logout",
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerificationRequest(),
                          ),
                        );
                      },
                      leading: const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                      ),
                      title: const Text("Become Verified User",
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ],
                );
              }
            }),
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          extendBody: true,
          body: pages[index],
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DotNavigationBar(
              backgroundColor: Colors.redAccent.shade400,
              margin: const EdgeInsets.only(left: 10, right: 10),
              currentIndex: index,
              dotIndicatorColor: Colors.white,
              unselectedItemColor: Colors.white,
              // enableFloatingNavBar: false,
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              items: [
                /// Home
                DotNavigationBarItem(
                  icon: Icon(Icons.home),
                  selectedColor: Colors.white,
                  unselectedColor: Colors.white,
                ),

                /// Add Box
                DotNavigationBarItem(
                  icon: Icon(Icons.add_box),
                  selectedColor: Colors.white,
                  unselectedColor: Colors.white,
                ),

                /// Profile
                DotNavigationBarItem(
                  icon: Icon(Icons.person),
                  selectedColor: Colors.white,
                  unselectedColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
