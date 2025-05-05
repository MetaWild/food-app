import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UseAuth extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _loading = true;

  UseAuth() {
    _auth.authStateChanges().listen((firebaseUser) {
      _user = firebaseUser;
      _loading = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get loading => _loading;
}