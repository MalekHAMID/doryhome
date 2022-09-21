import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doryhome/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class SingleHostel extends StatefulWidget {
  SingleHostel({required this.id});
  String id;
  @override
  State<SingleHostel> createState() => _SingleHostelState();
}

class _SingleHostelState extends State<SingleHostel> {
  String url(String phone, String message) {
    if (Platform.isAndroid) {
      // add the [https]
      return "whatsapp://send?phone=+90" + phone + "&text= ";
    } else {
      // add the [https]
      return "https://api.whatsapp.com/send?phone=$phone=${Uri.parse(message)}"; // new line
    }
  }

  String getFileName(String url) {
    RegExp regExp = new RegExp(r'.+(\/|%2F)(.+)\?.+');
    //This Regex won't work if you remove ?alt...token
    var matches = regExp.allMatches(url);

    var match = matches.elementAt(0);
    print("${Uri.decodeFull(match.group(2)!)}");
    return Uri.decodeFull(match.group(2)!);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: hostels.doc(widget.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.redAccent.shade400,
            )),
          );
        } else {
          return Scaffold(
            floatingActionButton: FutureBuilder<DocumentSnapshot>(
              future: users.doc(snapshot.data!.get('poster')).get(),
              builder: (context, ss) {
                if (!ss.hasData) {
                  return Container();
                } else {
                  return FloatingActionButton(
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.whatsapp,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      launch(url("${ss.data!.get('phone')}", ""));
                    },
                  );
                }
              },
            ),
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.redAccent.shade400,
              elevation: 1,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    snapshot.data!.get("poster") ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? PopupMenuItem(
                            onTap: () async {
                              try {
                                for (var image
                                    in snapshot.data!.get('images')) {
                                  final desertRef =
                                      storageRef.child(getFileName(image));

                                  await desertRef.delete();
                                }
                                await hostels.doc(snapshot.data!.id).delete();
                                await users
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('hostels')
                                    .doc(snapshot.data!.id)
                                    .delete();
                                Navigator.pop(context);
                              } catch (e) {}
                            },
                            child: Text("Delete"),
                          )
                        : const PopupMenuItem(
                            child: Text("Share"),
                          ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15, top: 15, right: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7.5),
                          topRight: Radius.circular(7.5)),
                    ),
                    child: ListTile(
                      leading: snapshot.data!.get('gender') == "male"
                          ? const Icon(
                              Icons.man,
                              color: Colors.blue,
                              size: 30,
                            )
                          : snapshot.data!.get("gender") == "female"
                              ? const Icon(
                                  Icons.woman,
                                  color: Colors.pink,
                                )
                              : const Icon(
                                  Icons.wc_rounded,
                                  color: Colors.green,
                                ),
                      title: Text(
                        snapshot.data!.get('room_type'),
                        //textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Container(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          snapshot.data!.get('rent') +
                              snapshot.data!.get('currency') +
                              " / Month",
                          //  textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      trailing: Text(
                        timeago
                            .format(snapshot.data!.get('createdAt').toDate())
                            .toString(),
                        //textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: const Divider(
                      color: Colors.black38,
                      indent: 50,
                      endIndent: 50,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: FlutterCarousel(
                      options: CarouselOptions(
                        height: 400.0,
                        showIndicator: true,
                        slideIndicator: const CircularSlideIndicator(),
                      ),
                      items: [
                        ...snapshot.data!
                            .get('images')
                            .map((e) => CachedNetworkImage(imageUrl: e))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    child: ListTile(
                      tileColor: snapshot.data!.get('bills_included')
                          ? Colors.green
                          : Colors.redAccent.shade400,
                      title: snapshot.data!.get('bills_included')
                          ? const Text(
                              "Bills are included",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          : const Text("Bills are not included",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  FutureBuilder<List<Location>>(
                      future: locationFromAddress(snapshot.data!.get('state') +
                          " , " +
                          snapshot.data!.get('city') +
                          " , " +
                          snapshot.data!.get('address')['mah']),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        } else {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            height: MediaQuery.of(context).size.height / 3,
                            child: FlutterMap(
                              options: MapOptions(
                                allowPanning: false,
                                allowPanningOnScrollingParent: false,
                                center: LatLng(snapshot.data!.first.latitude,
                                    snapshot.data!.first.longitude),
                                zoom: 12.5,
                              ),
                              layers: [
                                TileLayerOptions(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                  userAgentPackageName:
                                      'dev.fleaflet.flutter_map.example',
                                ),
                                MarkerLayerOptions(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                          snapshot.data!.first.latitude,
                                          snapshot.data!.first.longitude),
                                      width: 100,
                                      height: 100,
                                      builder: (context) => Icon(
                                        Icons.circle,
                                        size: 250,
                                        color: Colors.redAccent.shade400
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      }),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    padding:
                        const EdgeInsets.only(top: 15, bottom: 15, left: 15),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade400,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      snapshot.data!.get('state') +
                          " , " +
                          snapshot.data!.get('city') +
                          " , " +
                          snapshot.data!.get('address')['mah'] +
                          " " +
                          snapshot.data!.get('address')['no'] +
                          " " +
                          snapshot.data!.get('address')['apt'],
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
