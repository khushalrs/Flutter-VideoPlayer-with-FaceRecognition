import 'package:aws_signin/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../landscape_player/landscape_player.dart';
import '../widgets/login.dart';

class EntryScreen extends StatefulWidget {
  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  AuthUser? _user = null;

  @override
  void initState() {
    super.initState();
    Amplify.Auth.getCurrentUser().then((user) {
      setState(() {
        _user = user;
        if (_user != null){
          Navigator.pushReplacementNamed(context, '/FaceRecognition');
        }
        else{
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => Login()));}
      });
    }).catchError((error) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Login()));
      print(error);}
    );
    /*Future.delayed(Duration(seconds: 1), () async{
      getChild();
    });*/
  }

  /*getChild(){
    Future.delayed(const Duration(seconds: 2), () async
    {
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: CircularProgressIndicator(color:Colors.white),
      ),
    );
  }
}