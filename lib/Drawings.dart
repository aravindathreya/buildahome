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

class DocumentObject extends StatefulWidget {
  var parent;
  var children;
  var drawing_id;

  DocumentObject(this.parent, this.children, this.drawing_id);
  
  @override
  DocumentObjectState createState() {
    return DocumentObjectState(this.parent, this.children, this.drawing_id);
  }
}
class DocumentObjectState extends State<DocumentObject> {
  var parent;
  var children;
  var drawing_id;
  bool vis = false;
  Icon _icon = Icon(Icons.expand_more);
  
  DocumentObjectState(this.parent, this.children, this.drawing_id);


  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[200],
              ),
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                vis ? _icon = Icon(Icons.expand_less) : _icon = Icon(Icons.expand_more);
                vis ? vis=false : vis = true;                
              });

            },
            child: Container(
              
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(this.parent.toString(), style: TextStyle(fontSize: 16),),
                  _icon,
                ],
              ),
            ),
          ),
          Visibility(
            visible: vis,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                for(int x=0;x<this.children.length;x++)
                  InkWell(
                    onTap: () => {
                      showDialog(context: context,child: AlertDialog(content: Text("Loading..."))),
                      _launchURL("https://www.buildahome.in/team/Drawings/"+children[x].toString()),
                    },
                    child: Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(children[x].toString(), style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold),),)
                  )
              ],
            )
          )
        ],
      )
    );
  }

}

class DocumentsState extends State<Documents> {

  var entries;
  var folders = [];
  var subfolders = {};
  var drawing_ids = {};
  call() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('project_id');
    var url = 'https://www.buildahome.in/api/view_all_documents.php?id=$id';
    var response = await http.get(url);
    

    setState(() {
      folders = [];
      subfolders = {};
      drawing_ids = {};
      entries = jsonDecode(response.body);
      for(int i=0;i<entries.length;i++){
        if(folders.contains(entries[i]['folder'])==false && entries[i]['folder'].trim()!="" ){
          folders.add(entries[i]['folder']);
        }
      }
      for(int i=0;i<folders.length;i++){
        for(int x=0;x<entries.length;x++){
          if(entries[x]["folder"]==folders[i]){
            if(subfolders.containsKey(folders[i])){
              subfolders[folders[i]].add(entries[x]["name"]);
              drawing_ids[folders[i]].add(entries[x]["doc_id"]);
              
            }
            else{
              subfolders[folders[i]] = [];
              drawing_ids[folders[i]] = [];
              subfolders[folders[i]].add(entries[x]["name"]);
              drawing_ids[folders[i]].add(entries[x]["doc_id"]);
            }
          }
        }
      }
      
    });

  }

  @override
  void initState() {
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
                child: DocumentObject(folders[Index].toString(), subfolders[folders[Index]], drawing_ids[folders[Index]] ),
              );
            },
          )
      ),
    );
  }
}
