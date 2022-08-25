import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference requests =
    FirebaseFirestore.instance.collection('requests');
firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref().child('images');
CollectionReference hostels = FirebaseFirestore.instance.collection('hostels');
CollectionReference apratments =
    FirebaseFirestore.instance.collection('apartment');
