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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[
            Icon(Icons.account_circle, size: 150.0, color: Colors.grey[700]),
            SizedBox(height: 15.0),
            Text(userName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 7.0),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.group),
              title: Text('Grup'),
            ),
            ListTile(
              selected: true,
              onTap: () {},
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.account_circle),
              title: Text('Profil'),
            ),
            ListTile(
              onTap: () async {
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthenticatePage()), (Route<dynamic> route) => false);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 170.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 100.0,
                backgroundImage: NetworkImage("http://c11.incisozluk.com.tr/res/incisozluk/11007/2/3511902_odd48.jpg"),
              ),
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('İsim Soyisim', style: TextStyle(fontSize: 17.0)),
                  Text(userName, style: TextStyle(fontSize: 17.0)),
                ],
              ),

              Divider(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Email', style: TextStyle(fontSize: 17.0)),
                  Text(email, style: TextStyle(fontSize: 17.0)),
                ],
              ),
              Divider(height: 20.0),
              SizedBox(height: 16),
              SizedBox(height: 16),
              SizedBox(height: 16),
              SizedBox(height: 16),
              SizedBox(height: 16),
              Text("PROFİL FOTOĞRAFI YÜKLE YADA DEĞİŞTİR",style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                  onTap: () {

                  },
                  child: Icon(Icons.add_circle, color: Colors.grey[700], size: 90.0)
              ),
            ],
          ),
        )
      ),
    );
  }
}