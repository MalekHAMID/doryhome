import 'dart:io';

import 'package:csc_picker/csc_picker.dart';
import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import '../data.dart';

class AddHostel extends StatefulWidget {
  AddHostel({Key? key}) : super(key: key);

  @override
  State<AddHostel> createState() => _AddHostelState();
}

class _AddHostelState extends State<AddHostel> {
  ImagePicker _picker = ImagePicker();
  bool _postLoading = false;
  List<XFile>? _images = [];
  String _currency = "TL";
  String postId = Uuid().v1();
  String? countryValue;
  String? stateValue;
  String? cityValue;
  List<String> downloadLinks = [];
  String _roomType = "shared";
  TextEditingController _rent = TextEditingController();
  TextEditingController _mahcad = TextEditingController();
  TextEditingController _no = TextEditingController();
  TextEditingController _apt = TextEditingController();
  TextEditingController _additioanlInformation = TextEditingController();
  bool _billsIncluded = false;
  pickImages() async {
    List<XFile>? images = await _picker.pickMultiImage();
    if (images == null || images.isEmpty) {
      return null;
    } else {
      setState(() {
        _images = images;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added Sucessfully"),
        ),
      );
    }
  }

  String _initalGenderVlaue = "male";

  Future selectImage(List<XFile>? files) async {
    try {
      List<String> uruu = [];
      int c = 0;
      for (XFile file in files!) {
        File fileToUpload = File(file.path);
        UploadTask uploadTask;

        uploadTask =
            storageRef.child("post_$c$postId.jpg").putFile(fileToUpload);
        TaskSnapshot storageSnap =
            await uploadTask.whenComplete(() => print('completed'));
        String downloadUrl = await storageSnap.ref.getDownloadURL();
        uruu.add(downloadUrl);
        print(downloadUrl);
        c = c + 1;
      }
      return uruu;
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  handleSumbition() async {
    try {
      setState(() {
        _postLoading = true;
      });
      downloadLinks = await selectImage(_images);
      if (_formKey.currentState!.validate() ||
          _images!.isNotEmpty ||
          _images != null) {
        var user =
            await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
        await hostels.doc(postId).set(
          {
            "id": postId,
            "poster": FirebaseAuth.instance.currentUser!.uid,
            "gender": _initalGenderVlaue,
            "images": downloadLinks,
            "rent": _rent.text,
            "currency": _currency,
            "state": stateValue,
            "room_type": _roomType,
            "bills_included": _billsIncluded,
            "city": cityValue,
            "address": {
              "mah": _mahcad.text,
              "no": _no.text,
              "apt": _apt.text,
            },
            "verified_post": user.get('verified_user'),
            "additional_information": _additioanlInformation.text,
            "createdAt": DateTime.now(),
          },
        );
        await users
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('hostels')
            .doc(postId)
            .set({
          "post_id": postId,
        });
        _additioanlInformation.clear();
        _apt.clear();
        _no.clear();
        _additioanlInformation.clear();
        _rent.clear();
        _images!.clear();
        setState(() {
          _postLoading = false;
        });
      } else {
        setState(() {
          _postLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "The Forms or images are not filled please make sure everything is filled"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _postLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: !_postLoading
            ? ListView(
                children: [
                  InkWell(
                    onTap: () async {
                      await pickImages();
                    },
                    child: _images!.isEmpty || _images == null
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            padding: const EdgeInsets.all(7.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                Icon(
                                  Icons.add_box_outlined,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.all(7.5),
                            child: Stack(
                              children: [
                                Image.file(File(_images![0].path)),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(7.5)),
                                    child: Text(
                                      _images!.length.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: const Text(
                            "Rent/Month",
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value == null) {
                                return "Fill this feild";
                              } else {
                                return null;
                              }
                            },
                            controller: _rent,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.5),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 4,
                          child: DropdownButton(
                            value: _currency,
                            items: ["USD", "TL"]
                                .map((e) => DropdownMenuItem(
                                      child: Text(e.toString()),
                                      value: e,
                                    ))
                                .toList(),
                            onChanged: (vlaue) {
                              setState(() {
                                _currency = vlaue.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: const Text(
                            "Room Type",
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: DropdownButton<String>(
                            value: _roomType,
                            items: ["shared", "individual"]
                                .map((e) => DropdownMenuItem(
                                      child: Text(e.toString()),
                                      value: e,
                                    ))
                                .toList(),
                            onChanged: (vlaue) {
                              setState(() {
                                _roomType = vlaue.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(250),
                          ),
                          activeColor: Colors.red,
                          checkColor: Colors.white,
                          title:
                              const Text("Are bills included in the rent ? "),
                          value: _billsIncluded,
                          onChanged: (value) {
                            setState(() {
                              _billsIncluded = value!;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Looking for male / female / does not matter",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.man,
                              color: Colors.blue,
                            ),
                            Icon(
                              Icons.woman,
                              color: Colors.pink,
                            ),
                            Icon(
                              Icons.wc,
                              color: Colors.green,
                            ),
                          ],
                        ),
                        CupertinoRadioChoice(
                          selectedColor: Colors.redAccent.shade400,
                          choices: const {
                            'male': "male",
                            "female": "female",
                            "Any": "any"
                          },
                          onChange: (value) {
                            setState(() {
                              _initalGenderVlaue = value;
                            });
                          },
                          initialKeyValue: _initalGenderVlaue,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Address",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CSCPicker(
                            currentCountry: "Turkey",
                            disableCountry: true,
                            defaultCountry: DefaultCountry.Turkey,
                            onCountryChanged: (country) {
                              setState(() {
                                countryValue = country;
                              });
                            },
                            onStateChanged: (state) {
                              setState(() {
                                stateValue = state;
                              });
                            },
                            onCityChanged: (city) {
                              setState(() {
                                cityValue = city;
                              });
                            }),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty || value == null) {
                              return "Fill this feild";
                            } else {
                              return null;
                            }
                          },
                          controller: _mahcad,
                          decoration: InputDecoration(
                            hintText: "MAH / CAD / SK",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7.5),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: Wrap(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty || value == null) {
                                      return "Fill this feild";
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _no,
                                  decoration: InputDecoration(
                                    hintText: "NO :",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.5),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                                width: 15,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty || value == null) {
                                      return "Fill this feild";
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _apt,
                                  decoration: InputDecoration(
                                    hintText: "APT :",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.5),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Additioanl Information",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: TextField(
                            controller: _additioanlInformation,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Additional Information",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.5),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            handleSumbition();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent.shade400,
                              borderRadius: BorderRadius.circular(7.5),
                            ),
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Lottie.asset("assets/uploading.json"),
      ),
    );
  }
}
