import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'NavMenu.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class Documents extends StatefulWidget {
  @override
  DocumentsState createState() {
    return DocumentsState();
  }
}


class DocumentsState extends State<Documents> {

  var entries;
  var folders = [];
  call() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('project_id');
    var url = 'https://www.buildahome.in/api/view_all_documents.php?id=$id';
    var response = await http.get(url);


    setState(() {
      folders = [];
      entries = jsonDecode(response.body);
      for(int i=0;i<entries.length;i++){
        if(folders.contains(entries[i]['folder'])==false && entries[i]['folder'].trim()!="" ){
          folders.add(entries[i]['folder']);
        }
      }
    });

  }

  @override
  void initState() {
    super.initState();
    call();
  }


  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(appTitle),
            leading: new IconButton(
                icon: new Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState.openDrawer()),
            backgroundColor: Color(0xFF000055),
          ),
          drawer: NavMenuWidget(),
          body: ListView.builder(
            itemCount: folders == null? 0 : folders.length ,
            itemBuilder: (BuildContext ctxt, int Index) {
              return Container(


                child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide()
                        )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[

                            Icon(Icons.image, color: Colors.black),
                            Container(
                                padding: EdgeInsets.only(left: 5),
                                width: MediaQuery.of(context).size.width-70,
                                child: Text(folders[Index].toString(), style: TextStyle(fontSize: 16),)
                            )
                          ],
                        ),
                        for(int x=0;x<entries.length;x++)
                          if(entries[x]["folder"]==folders[Index])
                            InkWell(
                              onTap: () => _launchURL("https://www.buildahome.in/api/view_doc.php?id=${entries[x]['doc_id']}"),
                              child: Container(
                                  margin: EdgeInsets.only(left: 30, top: 10),
                                  width: MediaQuery.of(context).size.width-100,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.keyboard_arrow_right),
                                      Container(
                                        width: MediaQuery.of(context).size.width-150,
                                        child:
                                        Text(
                                          entries[x]["name"]+"  ",
                                          style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Icon(Icons.launch),
                                    ],
                                  )
                              )
                            ),
                      ],
                    ),
                )
              );



            },
          )
      ),
    );
  }
}
