import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'NavMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class NonTenderTaskWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'buildAhome';

    final GlobalKey<ScaffoldState> _scaffoldKey =
    new GlobalKey<ScaffoldState>();
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(fontFamily: MyApp().fontName),
      home: Scaffold(
        key: _scaffoldKey, // ADD THIS LINE
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
        drawer: NavMenuWidget(),
        body: PaymentTasksClass(),
      ),
    );
  }
}

class PaymentTasksClass extends StatefulWidget {
  @override
  PaymentTasks createState() {
    return PaymentTasks();
  }
}

class TaskItem extends StatefulWidget {
  String _Task_name;
  var _icon = Icons.home;
  var _start_date;
  var _end_date;
  var _height;
  var _color = Colors.white;
  var _payment_percentage;
  var status;

  TaskItem(this._Task_name, this._start_date, this._end_date,
      this._payment_percentage, this.status);

  @override
  TaskItemWidget createState() {
    return TaskItemWidget(this._Task_name, this._icon, this._start_date,
        this._end_date, this._color, this._height, this._payment_percentage, this.status);
  }
}

class TaskItemWidget extends State<TaskItem> with SingleTickerProviderStateMixin {
  String _Task_name;
  var _icon = Icons.home;
  var _start_date;
  var _end_date;
  var _color;
  var vis = false;
  var _payment_percentage;
  var _text_color = Colors.black;
  var _height = 50.0;
  var spr_radius = 1.0;
  var pad = 10.0;
  var value_str;
  var value =0;
  var status;
  var amt;

  @override
  void initState() {
    super.initState();
    _set_value();
    _progress();

  }

  _set_value() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    value_str = prefs.getString('project_value');
    value = int.parse(value_str);
    setState(() {
      amt = ((int.parse(this._payment_percentage))/100 ) * value;

    });
  }
  _progress() {

    if (this.status=='not due')
    {
      this._color = Colors.white;
      this._text_color = Colors.black;
    }
    else if (this.status=='paid'){
      this._color = Colors.green;
      this._text_color = Colors.white;
    }
    else{
      this._color = Colors.deepOrange;
      this._text_color = Colors.white;
    }
  }

  var view = Icons.expand_more;

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
      this._color, this._height, this._payment_percentage, this.status);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                  color: this._color,
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.grey[400],
                        blurRadius: 10,
                        spreadRadius: this.spr_radius,
                        offset: Offset(0.0, 10.0))
                  ],
                  border: Border.all(color: Colors.black, width: 2.0)),
              padding: EdgeInsets.all(this.pad),
              child: Container(
                decoration: BoxDecoration(
                  color: this._color,
                ),
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
                                width: MediaQuery.of(context).size.width * .8,
                                child: Text(
                                  this._Task_name,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: this._text_color,
                                  ),
                                ),
                              ),
                              new Icon(view, color: this._text_color),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: this.vis,
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                this._payment_percentage + "%     ₹ "+amt.toString(),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: this._text_color),
                              )
                            ],
                          ))),
                ]),
              ),
            )),
      ],
    );
  }
}

class PaymentTasks extends State<PaymentTasksClass> {
  var body;

  @override
  void initState() {
    super.initState();
    call();
  }

  var tasks = [];

  call() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('project_id');
    var url = 'https://www.buildahome.in/api/get_all_non_tender.php?project_id=$id ';
    var response = await http.get(url);
    setState(() {
      body = jsonDecode(response.body);
    });
  }

  ScrollController _controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      Container(
          padding: EdgeInsets.only(top: 20, left: 10, bottom: 10),
          decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 6.0, color: Colors.indigo[900]),
              )),
          child: Text("Non Tender Payments",
              style: TextStyle(
                fontSize: 20,
              ))),
      Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        border: Border.all()
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("Due")),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.green
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("Paid")
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all()
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("Ongoing tasks"))
                ],
              ),
            ),
          ],
        ),
      ),
      new ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: body == null ? 0 : body.length,
          itemBuilder: (BuildContext ctxt, int Index) {
            return Container(
              child: TaskItem(

                  body[Index]['task_name'].toString(),
                  body[Index]['start_date'].toString(),
                  body[Index]['end_date'].toString(),
                  body[Index]['payment'].toString(),
                  body[Index]['paid'].toString()
              ),


            );
          }),
    ]);
  }
}
