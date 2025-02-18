import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../NavMenu.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../main.dart';

import "Dpr.dart";
import "Payments.dart";
import "Gallery.dart";
import 'Drawings.dart';

class TaskWidget extends StatefulWidget{
  var id;
  TaskWidget(this.id);

  @override
  State<TaskWidget> createState() => TaskWidget1(this.id);

}

class TaskWidget1 extends State<TaskWidget> {
  var id;
  var role = "";
  TaskWidget1(this.id);

  call() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    call();
  }

  @override
  Widget build(BuildContext context) {


    final appTitle = 'buildAhome';
    final GlobalKey<ScaffoldState> _scaffoldKey =
    new GlobalKey<ScaffoldState>();
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(fontFamily: MyApp().fontName),
      home: Scaffold(
        key: _scaffoldKey,
        drawer: NavMenuWidget(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(appTitle),
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios),
              onPressed: () =>
              {
                Navigator.pop(context),
              }),
          backgroundColor: Color(0xFF000055),
        ),
        body: TaskScreenClass(this.id),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3,
          selectedItemColor: Colors.indigo[900],
          onTap: (int index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dpr(this.id)),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Documents(this.id)),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Gallery(this.id)),
              );
            } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TaskWidget(this.id)),
                );
            } else if (index == 4) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentTaskWidget(this.id)),
              );
            }
          },
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              title: Text(
                'Home',
                style: TextStyle(fontSize: 12),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.picture_as_pdf,
              ),
              title: Text(
                'Drawings',
                style: TextStyle(fontSize: 12),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.photo_album,
              ),
              title: Text(
                "Gallery",
                style: TextStyle(fontSize: 12),
              ),
            ),
            if (role == 'Site Engineer' || role == "Admin" || role == 'Project Coordinator')
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.access_time,
                ),
                title: Text(
                  'Scheduler',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            if (role == 'Project Coordinator' || role == "Admin")
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.payment,
                ),
                title: Text(
                  'Payment',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              
          ],
        ),
        
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  String _Task_name;
  var _icon = Icons.home;
  var _start_date;
  var _end_date;
  var _height;
  var _color = Colors.white;
  var _sub_tasks;
  var _progressStr;
  var note;

  TaskItem(this._Task_name, this._start_date, this._end_date, this._sub_tasks,
      this._progressStr, this.note);

  @override
  TaskItemWidget createState() {
    return TaskItemWidget(
        this._Task_name,
        this._icon,
        this._start_date,
        this._end_date,
        this._progressStr,
        this._color,
        this._height,
        this._sub_tasks,
        this.note);
  }
}

class TaskItemWidget extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  String _Task_name;
  var _icon = Icons.home;
  var _start_date;
  var _end_date;
  var _color;
  var vis = false;
  var _sub_tasks;
  var _text_color = Colors.black;
  var _height = 50.0;
  var spr_radius = 1.0;
  var pad = 10.0;
  var _progressStr;
  var note;
  var view = Icons.expand_more;
  var notes;

  @override
  void initState() {
    super.initState();
    call();
  }

  call() {
    var total = this._sub_tasks.split("^");
    var done = (this._progressStr.split("|"));
    notes = (this.note.split("|"));
    print(notes);
    if (((done.length - 1) / (total.length - 1)) > 0.9) {
      setState(() {
        this._text_color = Colors.green[600];
      });
    }
  }

  _progress() {
    var total = this._sub_tasks.split("^");
    var done = (this._progressStr.split("|"));
    return ((done.length - 1) / (total.length - 1));
  }

  _expand_collapse() {
    setState(() {
      if (vis == false) {
        vis = true;
        view = Icons.expand_less;
        spr_radius = 1.0;
      } else if (vis == true) {
        vis = false;
        view = Icons.expand_more;
        spr_radius = 1.0;
      }
    });
  }

  TaskItemWidget(this._Task_name, this._icon, this._start_date, this._end_date,
      this._progressStr, this._color, this._height, this._sub_tasks, this.note);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            color: this._color,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.grey[400],
                        blurRadius: 10,
                        spreadRadius: this.spr_radius,
                        offset: Offset(0.0, 10.0))
                  ],
                  border: Border.all(color: Colors.black, width: 2.0)),
              child: Container(
                decoration: BoxDecoration(
                  color: this._color,
                ),
                padding: EdgeInsets.all(this.pad),
                child: Column(children: <Widget>[
                  AnimatedContainer(
                    duration: Duration(milliseconds: 900),
                    padding: EdgeInsets.only(left: 7),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: _expand_collapse,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * .8,
                                child: Text(
                                  this._Task_name,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: _text_color,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              new Icon(view, color: Colors.indigo[600]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: this.vis,
                    child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[

                                Container(
                                    padding: EdgeInsets.only(left: 7, top: 10),
                                    child: Text(
                                      DateFormat("dd MMM")
                                          .format(
                                          DateTime.parse(this._start_date))
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    )),
                                Container(
                                    padding: EdgeInsets.only(right: 7, top: 10),
                                    child: Text(
                                      DateFormat("dd MMM")
                                          .format(
                                          DateTime.parse(this._end_date))
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ))
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 0, bottom: 10),
                              child: LinearPercentIndicator(
                                lineHeight: 8.0,
                                percent: _progress(),
                                animation: true,
                                animationDuration: 200,
                                backgroundColor: Colors.grey[300],
                                progressColor: Colors.indigo[500],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 15),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                  this._sub_tasks
                                      .split("^")
                                      .length - 1,
                                  itemBuilder: (BuildContext ctxt, int Index) {
                                    var sub_tasks = _sub_tasks.split("^");

                                    var each_task = sub_tasks[Index].split("|");
                                    if(each_task[0]!="")
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Wrap(
                                          children: <Widget>[
                                            Icon(Icons.arrow_right),
                                            Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width *
                                                    .75,
                                                child: Text(
                                                  DateFormat("dd MMM")
                                                      .format(DateTime.parse(
                                                      each_task[1]
                                                          .toString()))
                                                      .toString() +
                                                      " to " +
                                                      DateFormat("dd MMM")
                                                          .format(
                                                          DateTime.parse(
                                                              each_task[2]
                                                                  .toString()))
                                                          .toString() +
                                                      " : " +
                                                      each_task[0].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                          ],
                                        ),
                                        if(notes.length>Index && notes[Index].trim()!="")

                                        Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              notes[Index],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ))
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        )),
                  ),
                ]),
              ),
            )),
      ],
    );
  }
}

class TaskScreenClass extends StatefulWidget {

  var id;

  TaskScreenClass(this.id);

  @override
  TaskScreen createState() {
    return TaskScreen(this.id);
  }
}

class TaskScreen extends State<TaskScreenClass> {
  var id;

  TaskScreen(this.id);

  @override
  void initState() {
    super.initState();
    call();
  }

  var body;
  var tasks = [];
  ScrollController _controller = new ScrollController();

  call() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var p_id = prefs.getString('project_id');

    if (p_id != null) {
      var url = 'https://www.buildahome.in/api/get_all_tasks.php?project_id=$p_id&nt_toggle=0';
      print(url);
      var response = await http.get(url);
      setState(() {
        body = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      Container(
          padding: EdgeInsets.only(top: 20, left: 10, bottom: 10),
          decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 6.0, color: Colors.indigo[900]),
              )),
          child: Text("What's done and what's not?",
              style: TextStyle(
                fontSize: 20,
              ))),
      new ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: body == null ? 0 : body.length,
          itemBuilder: (BuildContext ctxt, int Index) {
            return Container(
              padding: EdgeInsets.only(bottom: 12, left: 5, right: 5, top: 5),
              child: TaskItem(
                  body[Index]['task_name'].toString(),
                  body[Index]['start_date'].toString(),
                  body[Index]['end_date'].toString(),
                  body[Index]['sub_tasks'].toString(),
                  body[Index]['progress'].toString(),
                  body[Index]['s_note'].toString()),
            );
          }),
    ]);
  }
}
