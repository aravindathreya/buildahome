import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../NavMenu.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

import "Dpr.dart";
import "Scheduler.dart";
import "Payments.dart";

var images = {};

class FullScreenImage extends StatelessWidget {
  var image;

  FullScreenImage(this.image);

  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: PhotoView(
          imageProvider: NetworkImage(this.image),
        ));
  }
}

class Gallery extends StatefulWidget{
  var id;

  Gallery(this.id);

  @override
  State<Gallery> createState() => Gallery1(this.id); 

}

class Gallery1 extends State<Gallery> {
  var id;

  Gallery1(this.id);
  var role = "";

  call() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role");
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
        // ADD THIS LINE
        drawer: NavMenuWidget(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(appTitle),
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios),
              onPressed: () => {
                    Navigator.pop(context),
                  }),
          backgroundColor: Color(0xFF000055),
        ),
        body: GalleryForm(this.id),
        bottomNavigationBar: BottomNavigationBar(
          
          currentIndex: 2,
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
                MaterialPageRoute(builder: (context) => TaskWidget(this.id)),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PaymentTaskWidget(this.id)),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Gallery(this.id)),
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
                Icons.access_time,
              ),
              title: Text(
                'Scheduler',
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
            if(role!="" && role!="Site Engineer")
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

class GalleryForm extends StatefulWidget {
  var id;

  GalleryForm(this.id);

  @override
  GalleryState createState() {
    return GalleryState(this.id);
  }
}

class GalleryState extends State<GalleryForm> {
  var id;

  GalleryState(this.id);

  @override
  void initState() {
    super.initState();
    call();
  }

  var entries_count = 0;
  var data = [];
  var entries;
  var a;
  var bytes;
  var updates = [];
  var subset = [];
  var pr_id;
  var dates = {};

  call() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pr_id = prefs.getString('project_id');

    var url = 'https://www.buildahome.in/api/get_gallery_data.php?id=$pr_id';

    var response = await http.get(url);
    entries = jsonDecode(response.body);
    entries_count = entries.length;
    for (int i = 0; i < entries_count; i++) {
      if (subset.contains(entries[i]['date']) == false) {
        setState(() {
          subset.add(entries[i]['date']);
        });
      }
    }
  }

  _image_func(_image_string, update_id) {
    var stripped = _image_string
        .toString()
        .replaceFirst(RegExp(r'data:image/jpeg;base64,'), '');
    var imageAsBytes = base64.decode(stripped);

    if (imageAsBytes != null) {
      var actual_image = new Image.memory(imageAsBytes);
      if (update_id != "From list") images[update_id] = _image_string;
      Uint8List bytes = base64Decode(stripped);
      return InkWell(
          child: actual_image,
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                        MemoryImage(bytes),
                      )),
            );
          });
    } else {
      return Container(
          padding: EdgeInsets.all(30),
          width: 100,
          height: 100,
          color: Colors.grey[100],
          child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        padding: EdgeInsets.all(10),
        shrinkWrap: true,
        itemCount: subset == null ? 0 : subset.length,
        itemBuilder: (BuildContext ctxt, int Index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 5, top: 10),
                child: Text(subset[Index],
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Wrap(
                children: <Widget>[
                  for (int i = 0; i < entries.length; i++)
                    if (entries[i]['date'] == subset[Index])
                      if (images.containsKey(entries[i]['image_id']))
                        Container(
                            width: (MediaQuery.of(context).size.width - 20) / 3,
                            height:
                                (MediaQuery.of(context).size.width - 20) / 3,
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            child: _image_func(
                                images[entries[i]['image_id']], "From list"))
                      else
                        Container(
                          width: (MediaQuery.of(context).size.width - 20) / 3,
                          height: (MediaQuery.of(context).size.width - 20) / 3,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: InkWell(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context1) => FullScreenImage(
                                          "https://buildahome.in/api/images/${entries[i]['image']}"
                                          )),
                                );
                              },
                              child: Image.network(
                                  "https://buildahome.in/api/images/${entries[i]['image']}")),
                        )
                ],
              )
            ],
          );
        });
  }
}
