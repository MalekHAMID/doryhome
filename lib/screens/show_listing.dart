import 'package:doryhome/partition%20screens/show_hostels.dart';
import 'package:doryhome/partition%20screens/show_tourstic_apartments.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ShowListings extends StatefulWidget {
  ShowListings({Key? key}) : super(key: key);

  @override
  State<ShowListings> createState() => _ShowListingsState();
}

class _ShowListingsState extends State<ShowListings> {
  int initialIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
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
      body: initialIndex == 0
          ? ShowHostel(
              id: null,
            )
          : ShowApartments(),
    );
  }
}
