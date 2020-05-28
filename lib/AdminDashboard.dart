import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'NavMenu.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'main.dart';
import 'Admin/Dpr.dart';

class AdminDashboard extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appTitle = 'buildAhome';

    return MaterialApp(
      title: appTitle,
      theme: ThemeData(fontFamily: MyApp().fontName),
      home: Scaffold(
        key: _scaffoldKey, // ADD THIS LINE
        drawer: NavMenuWidget(),

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            appTitle,
          ),
          leading: new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var username = prefs.getString('username');
                _scaffoldKey.currentState.openDrawer();
              }),
          backgroundColor: Color(0xFF000055),
        ),
        body: Dashboard(),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard> {
  var update = " ";
  var username = ' ';
  var date = " ";
  var role = "";
  var value = " ";
  var completed = "0";
  var user_id ;

  @override
  void initState() {
    super.initState();
    call();
  }

  call() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    var id = prefs.getString('project_id');
    user_id = prefs.getString('user_id');

    setState(() {
      value = prefs.getString('project_value');
      completed = prefs.getString('completed');
      username = prefs.getString('username');
    });
  }

  Widget build(BuildContext context) {
    return Container(
//        padding: EdgeInsets.all(20),
        child: ListView(
      padding: EdgeInsets.all(25),
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 10),
          margin: EdgeInsets.only(bottom: 10, right: 100),
          child: Text("Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 3))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                alignment: Alignment.centerLeft,
                width: (MediaQuery.of(context).size.width - 60) / 2,
                margin: EdgeInsets.only(bottom: 10),
                child: Text("Name",
                    style: TextStyle(color: Colors.grey[600], fontSize: 18))),
            Container(
                alignment: Alignment.centerLeft,
                width: (MediaQuery.of(context).size.width - 60) / 2,
                margin: EdgeInsets.only(bottom: 10),
                child: Text(username,
                    style: TextStyle(color: Colors.black, fontSize: 18))),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                alignment: Alignment.centerLeft,
                width: (MediaQuery.of(context).size.width - 60) / 2,
                margin: EdgeInsets.only(bottom: 30),
                child: Text("Role",
                    style: TextStyle(color: Colors.grey[600], fontSize: 18))),
            Container(
                alignment: Alignment.centerLeft,
                width: (MediaQuery.of(context).size.width - 60) / 2,
                margin: EdgeInsets.only(bottom: 30),
                child: Text(role,
                    style: TextStyle(color: Colors.black, fontSize: 18))),
          ],
        ),
        Container(
          padding: EdgeInsets.only(bottom: 10),
          margin: EdgeInsets.only(bottom: 10, right: 100),
          child: Text("Projects handled by you",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 3))),
        ),
        Container(
            child: FutureBuilder(

                future: http.get(
                  "https://www.buildahome.in/api/projects_access.php?id=${user_id}",
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text('Press button to start.');
                    case ConnectionState.active:

                    case ConnectionState.waiting:
                      return Container(
                        padding: EdgeInsets.only(top: 20),
                        child: SpinKitThreeBounce(
                          color: Colors.indigo[900],
                          size: 30.0,
                        ),
                      );

                    case ConnectionState.done:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      var projects = jsonDecode(snapshot.data.body);
                      return ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            ListView.builder(
                                shrinkWrap: true,
                                physics: new BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: projects.length,
                                itemBuilder: (BuildContext ctxt, int Index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Dpr(projects[Index]['id'])),
                                      );
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.rectangle,
                                          border: Border(
                                            bottom: BorderSide(
                                                width: 1.0,
                                                color: Colors.black54),
                                          ),
                                          boxShadow: [
                                            new BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            )
                                          ],
                                        ),
                                        child: Container(
                                            child: Text(projects[Index]['name'],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight.bold))))
                                  );
                                })
                          ]);
                  }
                })),
      ],
    ));
  }
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
