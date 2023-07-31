import 'dart:convert';
import 'dart:io';
import 'package:aws_signin/landscape_player/landscape_player.dart';
import 'package:aws_signin/utils/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../ML/Recognition.dart';
import 'entry.dart';

class DashboardScreen extends StatefulWidget {
  String name;
  DashboardScreen({required this.name});

  @override
  _DashboardScreenState createState() => _DashboardScreenState(name);
}


class _DashboardScreenState extends State<DashboardScreen> {
  String name;
  _DashboardScreenState(this.name);
  AuthUser? _user = null;
  late List<Map<String,dynamic>> data;
  Map<String, Recognition> registered = {};
  List<String> names = [];

  void readData() async {
    print("Inside ReadData");
    List<Map<String,dynamic>> _data = [];
    if(mockData.containsKey(name)){
      _data = mockData[name];
    }
    else{
      _data = mockData["default"];
    }
    setState(() {
      data=_data;
    });
    //print("Items: $items");
  }

  @override
  void initState() {
    super.initState();
    readData();
    _readValue();
    Amplify.Auth.getCurrentUser().then((user) {
      setState(() {
        _user = user;
      });
    }).catchError((error) {
      print(error);
    });
  }

  void _readValue() async{
    try {
      final directory = await getApplicationDocumentsDirectory();
      //print("Directory : ${directory.path}");
      final file = File('${directory.path}/registered.txt');
      if(await file.exists()){
        print("File Exists");
      }
      String text = await file.readAsString();
      print("Data found : $text");
      Map<String,dynamic> r = jsonDecode(text);
      r.forEach((key, value) {
        Map<String,Recognition> m = {key : Recognition.fromJson(value)};
        setState(() {
          registered.addAll(m);
        });
      });
      setState(() {
        names = registered.keys.toList();
      });
      //print("Registered : ${r['khushal'].runtimeType}");
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FaceList(name, names, registered),
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          MaterialButton(
            onPressed: () {
              Amplify.Auth.signOut().then((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EntryScreen()));
              });
            },
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisSpacing: 12,mainAxisSpacing: 15,crossAxisCount: 2,childAspectRatio: 0.65),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return new GestureDetector(
            onTap: () {
              List<String> send = [data[index]["trailer_url"], name];
              Navigator.of(context).pushReplacementNamed('/landscape', arguments: send);
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(data[index]["image"]),
                ),
              ),
            ),
          );
        },
      )
    );
  }
}

class FaceList extends StatelessWidget{

  void _writeValue(String name) async{
    registered.remove(name);
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    var file = File("$path/registered.txt");
    if(await file.exists()){
      file.delete();
    }
    String text = jsonEncode(registered);
    await file.writeAsString(text, mode:FileMode.writeOnly);
  }

  Map<String, Recognition> registered;
  List<String> names;
  String name;
  FaceList(this.name, this.names, this.registered);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        itemCount: names.length+1,
        padding: EdgeInsets.zero,
        itemBuilder: (context, int index){
          if(index==0) {
            return DrawerHeader(
                child: Text("Hello, $name",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 25))
            );
          }
          else{
            return names.isEmpty ? Center(child: CircularProgressIndicator()) : ListTile(
              title: Text(names[index-1]),
              onTap: () => {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Do you want to delete face?", textAlign: TextAlign.center),alignment: Alignment.center,
                      content: SizedBox(
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20,),
                            ElevatedButton(onPressed: (){
                              _writeValue(names[index-1]);
                              Navigator.pop(context);},
                              child: const Text("Confirm"))
                          ],
                        ),
                      )
                  )
                )
              },
            );
          }
        }
      )
    );
  }

}