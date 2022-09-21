import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doryhome/data.dart';
import 'package:doryhome/partition%20screens/signle_hostel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class ShowHostel extends StatefulWidget {
  ShowHostel({required this.id});
  String? id;
  @override
  State<ShowHostel> createState() => _ShowHostelState();
}

class _ShowHostelState extends State<ShowHostel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.id == null
            ? hostels.snapshots()
            : hostels.where('poster', isEqualTo: widget.id).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Lottie.asset('assets/empty.json');
          } else {
            return ListView(
              children: snapshot.data!.docs.map(
                (e) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SingleHostel(id: e.id),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 1,
                            spreadRadius: 0.01,
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(7.5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                            child: ListTile(
                              leading: e.get('gender') == "male"
                                  ? const Icon(
                                      Icons.man,
                                      color: Colors.blue,
                                      size: 30,
                                    )
                                  : e.get("gender") == "female"
                                      ? const Icon(
                                          Icons.woman,
                                          color: Colors.pink,
                                        )
                                      : const Icon(
                                          Icons.wc_rounded,
                                          color: Colors.green,
                                        ),
                              title: Text(
                                e.get('room_type'),
                                //textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Container(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8.0),
                                child: Text(
                                  e.get('rent') +
                                      e.get('currency') +
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
                                    .format(e.get('createdAt').toDate())
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
                          const Divider(
                            indent: 0,
                            endIndent: 0,
                            color: Colors.black26,
                          ),
                          FlutterCarousel(
                            options: CarouselOptions(
                              height: 400.0,
                              showIndicator: true,
                              slideIndicator: const CircularSlideIndicator(),
                            ),
                            items: [
                              ...e.get('images').map((s) => CachedNetworkImage(
                                    imageUrl: s,
                                    fit: BoxFit.cover,
                                  ))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Icon(
                                    Icons.room,
                                    size: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8.0),
                                  child: Text(
                                    e.get('state') + " , " + e.get("city"),
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                e.get('verified_post')
                                    ? Row(
                                        children: const [
                                          Text(
                                            "Verified Listing",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.lightBlue),
                                          ),
                                          Icon(
                                            Icons.verified,
                                            color: Colors.lightBlue,
                                          ),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          const Divider(
                            endIndent: 200,
                            indent: 0,
                          ),
                          Container(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Wrap(children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    e.get('additional_information'),
                                    maxLines: 5,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.visible,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15)),
                              color: e.get("bills_included")
                                  ? Colors.green
                                  : Colors.redAccent.shade400,
                            ),
                            child: e.get("bills_included")
                                ? const Text(
                                    "Bills are included",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  )
                                : const Text(
                                    "Bills are not included",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          }
        },
      ),
    );
  }
}
