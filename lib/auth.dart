import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'pages/app/home/home.dart';
import 'pages/authenticate/authenticate.dart';

class Auth extends StatefulWidget {
  static const routeName = 'auth';

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool isLoggedIn;
  StreamSubscription authStateSub;
  Timer checkAuthTimer;

  @override
  void initState() {
    super.initState();
    final auth = GetIt.I.get<FirebaseAuth>();

    authStateSub = auth.onAuthStateChanged
        .listen((user) => setState(() => isLoggedIn = user != null));

    checkAuthTimer = Timer(
      Duration(seconds: 1),
      () async {
        if (isLoggedIn == null) {
          final user = await auth.currentUser();
          setState(() => isLoggedIn = user != null);
        }
      },
    );
  }

  @override
  void dispose() {
    authStateSub.cancel();
    if (checkAuthTimer.isActive) checkAuthTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (isLoggedIn) {
      case true:
        return Home();
      case false:
        return Authenticate();
      default:
        return _loadingWidget();
    }
  }
}

Widget _loadingWidget() => Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
