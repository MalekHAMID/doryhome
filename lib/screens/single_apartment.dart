import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doryhome/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class SingleApartment extends StatefulWidget {
  SingleApartment({required this.id});
  final String id;
  @override
  State<SingleApartment> createState() => _SingleApartmentState();
}

class _SingleApartmentState extends State<SingleApartment> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: apratments.doc(widget.id).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(left: 15, top: 15, right: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7.5),
                            topRight: Radius.circular(7.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            snapshot.data!.get('house_type'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            snapshot.data!.get('rent') +
                                " " +
                                snapshot.data!.get('currency'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Text(
                            timeago
                                .format(
                                    snapshot.data!.get('createdAt').toDate())
                                .toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade400,
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade400,
                      ),
                    ),
                    snapshot.data!.get('poster') ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? Container(
                            margin: const EdgeInsets.only(left: 15, right: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15))),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      print(snapshot.data!.get('images'));
                                      for (var image
                                          in snapshot.data!.get('images')) {
                                        final desertRef = storageRef
                                            .child(getFileName(image));

                                        await desertRef.delete();
                                      }
                                      await apratments
                                          .doc(snapshot.data!.id)
                                          .delete();
                                      await users
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('aparts')
                                          .doc(snapshot.data!.id)
                                          .delete();
                                      Navigator.pop(context);
                                    } catch (e) {}
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      child: ListTile(
                        tileColor: snapshot.data!.get('bills_included')
                            ? Colors.green
                            : Colors.red,
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
                    Container(
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15))),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: users.doc(snapshot.data!.get('poster')).get(),
                        builder: (context, dataa) {
                          if (!dataa.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return ListTile(
                              leading: dataa.data!.get('verified_user')
                                  ? const Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                    )
                                  : Container(),
                              title: Text(
                                dataa.data!.get('username'),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  launch(url(dataa.data!.get('phone'), " "));
                                },
                                icon: const Icon(
                                  Icons.whatsapp_rounded,
                                  size: 45,
                                  color: Colors.green,
                                ),
                              ),
                              subtitle: Text(
                                  snapshot.data!.get('additional_information')),
                            );
                          }
                        },
                      ),
                    ),
                    FutureBuilder<List<Location>>(
                        future: locationFromAddress(
                            snapshot.data!.get('state') +
                                " , " +
                                snapshot.data!.get('city') +
                                " , " +
                                snapshot.data!.get('address')['mah']),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          } else {
                            return Container(
                              margin: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              height: MediaQuery.of(context).size.height / 3,
                              child: FlutterMap(
                                options: MapOptions(
                                  allowPanningOnScrollingParent: false,
                                  center: LatLng(snapshot.data!.first.latitude,
                                      snapshot.data!.first.longitude),
                                  zoom: 12,
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
                                        width: 80,
                                        height: 80,
                                        builder: (context) => Icon(
                                          Icons.circle,
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
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
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
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
