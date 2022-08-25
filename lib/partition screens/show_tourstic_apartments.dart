import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doryhome/data.dart';
import 'package:doryhome/screens/single_apartment.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShowApartments extends StatefulWidget {
  ShowApartments({Key? key}) : super(key: key);

  @override
  State<ShowApartments> createState() => _ShowApartmentsState();
}

class _ShowApartmentsState extends State<ShowApartments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: apratments.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Lottie.asset('assets/empty.json');
          } else {
            return ListView(
              children: snapshot.data!.docs.map((e) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleApartment(id: e.id),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 3.6,
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
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                e.get('house_type'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                e.get('rent') + " " + e.get('currency'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              Text(
                                timeago
                                    .format(e.get('createdAt').toDate())
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
                        const Divider(
                          indent: 0,
                          endIndent: 0,
                          color: Colors.black26,
                        ),
                        Container(
                          decoration: const BoxDecoration(color: Colors.white),
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(7.5),
                          child: CachedNetworkImage(
                            imageUrl: e.get('images')[0],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            children: [
                              const Icon(
                                Icons.room,
                                color: Colors.red,
                              ),
                              Text(
                                e.get('state') + " , " + e.get("city"),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
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
                          padding: const EdgeInsets.all(7.5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                e.get('additional_information').isNotEmpty
                                    ? const Align(
                                        alignment: Alignment.topLeft,
                                        child: Icon(
                                          Icons.info,
                                          color: Colors.amber,
                                        ),
                                      )
                                    : Container(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  e.get('additional_information'),
                                  maxLines: 5,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: e.get("bills_included")
                                ? Colors.green
                                : Colors.red,
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
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
