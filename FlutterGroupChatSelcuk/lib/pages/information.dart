import 'package:flutter/material.dart';
import 'package:group_chat_app/pages/authenticate_page.dart';
import 'package:group_chat_app/pages/home_page.dart';
import 'package:group_chat_app/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:group_chat_app/pages/authenticate_page.dart';
import 'package:group_chat_app/pages/home_page.dart';
import 'package:group_chat_app/services/auth_service.dart';

class ProfilePage extends StatelessWidget {

  final String userName;
  final String email;
  final AuthService _auth = AuthService();

  ProfilePage({this.userName, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        elevation: 0.0,
      ),
    );
  }
}