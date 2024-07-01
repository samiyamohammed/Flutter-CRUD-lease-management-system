// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task4/lease%20management/pages/lease_management_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC1Es2-qq9hWFBTFJOIom60i5e_vjP6lmI",
      projectId: "lease-management-firebase",
      storageBucket: "lease-management-firebase.appspot.com",
      messagingSenderId: "36732733105",
      appId: "1:36732733105:android:dae0d6484f697b36888490",
    ),
  );
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LeaseManagementPage(),
    );
  }
}
