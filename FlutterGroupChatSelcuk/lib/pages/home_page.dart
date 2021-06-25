import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/helper/helper_functions.dart';
import 'package:group_chat_app/pages/authenticate_page.dart';
import 'package:group_chat_app/pages/chat_page.dart';
import 'package:group_chat_app/pages/profile_page.dart';
import 'package:group_chat_app/pages/search_page.dart';
import 'package:group_chat_app/services/auth_service.dart';
import 'package:group_chat_app/services/database_service.dart';
import 'package:group_chat_app/widgets/group_tile.dart';
import 'package:group_chat_app/pages/chat_page.dart';
import 'package:flutter/animation.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // data
  final AuthService _auth = AuthService();
  FirebaseUser _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream _groups;


  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }


  // widgets
  Widget noGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _popupDialog(context);
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75.0)
          ),
          SizedBox(height: 20.0),
          Text("Herhangi bir gruba katılmadınız, bir grup oluşturmak için 'ekle' simgesine dokunun veya aşağıdaki arama düğmesine dokunarak grupları arayın."),
        ],
      )
    );
  }



  Widget groupsList() {
    return StreamBuilder(
      stream: _groups,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data['groups'] != null) {
            // print(snapshot.data['groups'].length);
            if(snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  int reqIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(userName: snapshot.data['fullName'], groupId: _destructureId(snapshot.data['groups'][reqIndex]), groupName: _destructureName(snapshot.data['groups'][reqIndex]));
                }
              );
            }
            else {
              return noGroupWidget();
            }
          }
          else {
            return noGroupWidget();
          }
        }
        else {
          return Center(
            child: CircularProgressIndicator()
          );
        }
      },
    );
  }


  // functions
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser();
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    DatabaseService(uid: _user.uid).getUserGroups().then((snapshots) {
      // print(snapshots);
      setState(() {
        _groups = snapshots;
      });
    });
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
  }


  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
  }


  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
  }


  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("İptal"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Oluştur"),
      onPressed:  () async {
        if(_groupName != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid).createGroup(val, _groupName);
          });
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Grup Oluştur"),
      content: TextField(
        onChanged: (val) {
          _groupName = val;
        },
        style: TextStyle(
          fontSize: 15.0,
          height: 2.0,
          color: Colors.black             
        )
      ),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gruplar', style: TextStyle(color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            icon: Icon(Icons.search, color: Colors.white, size: 25.0),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
            }
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          children: <Widget>[
            CircleAvatar(
              radius: 100.0,
              backgroundImage: NetworkImage("http://c11.incisozluk.com.tr/res/incisozluk/11007/2/3511902_odd48.jpg"),
            ),
            SizedBox(height: 15.0),
            Text("AD: "+_userName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15.0),
            Text("Biyografin: Bitmez Dediğin Ne Bitmedi", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 7.0),
            ListTile(
              onTap: () {},
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.group),
              title: Text('Gruplar'),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage(userName: _userName, email: _email)));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.account_circle),
              title: Text('Profil Bilgilerin'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>Profilci()));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.help),
              title: Text('Hakkında'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>Durum()));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.add_circle_outline_sharp),
              title: Text('Durum'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>Camera()));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.camera_alt),
              title: Text('Kamera'),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>ScatterChartSample1()));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.arrow_forward_ios),
              title: Text('Ekstra Animasyon'),
            ),
            ListTile(
              onTap: () async {
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthenticatePage()), (Route<dynamic> route) => false);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      body: groupsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popupDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.0),
        backgroundColor: Colors.grey[700],
        elevation: 0.0,
      ),
    );
  }
}

class Profilci extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text("                                                                                                                                                                                                                                                                                                                                 "),
            Text("Bu uygulama Dr. Öğretim Üyesi Ahmet Cevahir ÇINAR tarafından yürütülen 3301456 kodlu MOBİL PROGRAMLAMA dersi kapsamında 793301010 numaralı ENES ÇAKMAK tarafından 25.06.2021 günü yapılmıştır.",style: TextStyle(fontWeight: FontWeight.bold)),
          ],

        ),
      ),
    );
  }
}

class Camera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 16),
            SizedBox(height: 16),
            Text("                                                                                                                                                                                                                                                                                                                                 "),
            Text("Kamera Bulunamadı (ERROR X80A423D)"),
          ],
        ),
      ),
    );
  }
}

class Durum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 16),
            SizedBox(height: 16),
            Text("DURUMLAR",style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(height: 16),
            GestureDetector(
                onTap: () {

                },
                child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75.0)
            ),
            ListTile(leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage("https://media.istockphoto.com/photos/angry-man-picture-id617742446"),
            ),
            title:  Text("İnsanların seni en çok sevdiği zaman onların işine en çok yaradığın zamandır -Bukowski"),
            ),
            SizedBox(height: 16),
            ListTile(leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage("https://inst-2.cdn.shockers.de/hs_cdn/out/pictures/master/product/1/muskelmann_kinderkostuem-wrestling_kostuem_fuer_kinder-bodybuilder_kinderkostuem-14325-2.jpg"),
            ),
              title:  Text("Tam pes etmek üzere olduğunuz anlarda, neden başladığınızı hatırlayın."),
            ),
            SizedBox(height: 16),
            ListTile(leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage("https://previews.123rf.com/images/na2xa/na2xa1711/na2xa171100436/89044633-super-happy-woman-shows-two-thumbs-up.jpg"),
            ),
              title:  Text("İyi yaşamak değil, yaşamayı iyi bitirmek. İşte gerçek mutluluk budur.",),
            ),
            SizedBox(height: 16),
            ListTile(leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage("http://c11.incisozluk.com.tr/res/incisozluk/11007/2/3511902_odd48.jpg"),
            ),
              title:  Text("Gazla uçabilirsin, ama frenle konamazsın."),
            ),
          ],
        ),
      ),
    );
  }
}

class ScatterChartSample1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScatterChartSample1State();
}

class _ScatterChartSample1State extends State {
  final maxX = 50.0;
  final maxY = 50.0;
  final radius = 8.0;

  Color blue1 = const Color(0xFF0D47A1);
  Color blue2 = const Color(0xFF42A5F5).withOpacity(0.8);

  bool showFlutter = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showFlutter = !showFlutter;
        });
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          color: const Color(0xffffffff),
          elevation: 6,
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: showFlutter ? flutterLogoData() : randomData(),
              minX: 0,
              maxX: maxX,
              minY: 0,
              maxY: maxY,
              borderData: FlBorderData(
                show: false,
              ),
              gridData: FlGridData(
                show: false,
              ),
              titlesData: FlTitlesData(
                show: false,
              ),
              scatterTouchData: ScatterTouchData(
                enabled: false,
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 600),
          ),
        ),
      ),
    );
  }

  List<ScatterSpot> flutterLogoData() {
    return [
      /// section 1
      ScatterSpot(20, 14.5, color: blue1, radius: radius),
      ScatterSpot(22, 16.5, color: blue1, radius: radius),
      ScatterSpot(24, 18.5, color: blue1, radius: radius),

      ScatterSpot(22, 12.5, color: blue1, radius: radius),
      ScatterSpot(24, 14.5, color: blue1, radius: radius),
      ScatterSpot(26, 16.5, color: blue1, radius: radius),

      ScatterSpot(24, 10.5, color: blue1, radius: radius),
      ScatterSpot(26, 12.5, color: blue1, radius: radius),
      ScatterSpot(28, 14.5, color: blue1, radius: radius),

      ScatterSpot(26, 8.5, color: blue1, radius: radius),
      ScatterSpot(28, 10.5, color: blue1, radius: radius),
      ScatterSpot(30, 12.5, color: blue1, radius: radius),

      ScatterSpot(28, 6.5, color: blue1, radius: radius),
      ScatterSpot(30, 8.5, color: blue1, radius: radius),
      ScatterSpot(32, 10.5, color: blue1, radius: radius),

      ScatterSpot(30, 4.5, color: blue1, radius: radius),
      ScatterSpot(32, 6.5, color: blue1, radius: radius),
      ScatterSpot(34, 8.5, color: blue1, radius: radius),

      ScatterSpot(34, 4.5, color: blue1, radius: radius),
      ScatterSpot(36, 6.5, color: blue1, radius: radius),

      ScatterSpot(38, 4.5, color: blue1, radius: radius),

      /// section 2
      ScatterSpot(20, 14.5, color: blue2, radius: radius),
      ScatterSpot(22, 12.5, color: blue2, radius: radius),
      ScatterSpot(24, 10.5, color: blue2, radius: radius),

      ScatterSpot(22, 16.5, color: blue2, radius: radius),
      ScatterSpot(24, 14.5, color: blue2, radius: radius),
      ScatterSpot(26, 12.5, color: blue2, radius: radius),

      ScatterSpot(24, 18.5, color: blue2, radius: radius),
      ScatterSpot(26, 16.5, color: blue2, radius: radius),
      ScatterSpot(28, 14.5, color: blue2, radius: radius),

      ScatterSpot(26, 20.5, color: blue2, radius: radius),
      ScatterSpot(28, 18.5, color: blue2, radius: radius),
      ScatterSpot(30, 16.5, color: blue2, radius: radius),

      ScatterSpot(28, 22.5, color: blue2, radius: radius),
      ScatterSpot(30, 20.5, color: blue2, radius: radius),
      ScatterSpot(32, 18.5, color: blue2, radius: radius),

      ScatterSpot(30, 24.5, color: blue2, radius: radius),
      ScatterSpot(32, 22.5, color: blue2, radius: radius),
      ScatterSpot(34, 20.5, color: blue2, radius: radius),

      ScatterSpot(34, 24.5, color: blue2, radius: radius),
      ScatterSpot(36, 22.5, color: blue2, radius: radius),

      ScatterSpot(38, 24.5, color: blue2, radius: radius),

      /// section 3
      ScatterSpot(10, 25, color: blue2, radius: radius),
      ScatterSpot(12, 23, color: blue2, radius: radius),
      ScatterSpot(14, 21, color: blue2, radius: radius),

      ScatterSpot(12, 27, color: blue2, radius: radius),
      ScatterSpot(14, 25, color: blue2, radius: radius),
      ScatterSpot(16, 23, color: blue2, radius: radius),

      ScatterSpot(14, 29, color: blue2, radius: radius),
      ScatterSpot(16, 27, color: blue2, radius: radius),
      ScatterSpot(18, 25, color: blue2, radius: radius),

      ScatterSpot(16, 31, color: blue2, radius: radius),
      ScatterSpot(18, 29, color: blue2, radius: radius),
      ScatterSpot(20, 27, color: blue2, radius: radius),

      ScatterSpot(18, 33, color: blue2, radius: radius),
      ScatterSpot(20, 31, color: blue2, radius: radius),
      ScatterSpot(22, 29, color: blue2, radius: radius),

      ScatterSpot(20, 35, color: blue2, radius: radius),
      ScatterSpot(22, 33, color: blue2, radius: radius),
      ScatterSpot(24, 31, color: blue2, radius: radius),

      ScatterSpot(22, 37, color: blue2, radius: radius),
      ScatterSpot(24, 35, color: blue2, radius: radius),
      ScatterSpot(26, 33, color: blue2, radius: radius),

      ScatterSpot(24, 39, color: blue2, radius: radius),
      ScatterSpot(26, 37, color: blue2, radius: radius),
      ScatterSpot(28, 35, color: blue2, radius: radius),

      ScatterSpot(26, 41, color: blue2, radius: radius),
      ScatterSpot(28, 39, color: blue2, radius: radius),
      ScatterSpot(30, 37, color: blue2, radius: radius),

      ScatterSpot(28, 43, color: blue2, radius: radius),
      ScatterSpot(30, 41, color: blue2, radius: radius),
      ScatterSpot(32, 39, color: blue2, radius: radius),

      ScatterSpot(30, 45, color: blue2, radius: radius),
      ScatterSpot(32, 43, color: blue2, radius: radius),
      ScatterSpot(34, 41, color: blue2, radius: radius),

      ScatterSpot(34, 45, color: blue2, radius: radius),
      ScatterSpot(36, 43, color: blue2, radius: radius),

      ScatterSpot(38, 45, color: blue2, radius: radius),
    ];
  }

  List<ScatterSpot> randomData() {
    const blue1Count = 21;
    const blue2Count = 57;
    return List.generate(blue1Count + blue2Count, (i) {
      Color color;
      if (i < blue1Count) {
        color = blue1;
      } else {
        color = blue2;
      }

      return ScatterSpot(
        (Random().nextDouble() * (maxX - 8)) + 4,
        (Random().nextDouble() * (maxY - 8)) + 4,
        color: color,
        radius: (Random().nextDouble() * 16) + 4,
      );
    });
  }
}

