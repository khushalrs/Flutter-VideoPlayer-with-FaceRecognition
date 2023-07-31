import 'package:aws_signin/landscape_player/landscape_player.dart';
import 'package:aws_signin/screens/Face.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'screens/entry.dart';
import 'screens/confirm.dart';
import 'screens/confirm_reset.dart';
import 'screens/dashboard.dart';
import 'helpers/configure_amplify.dart';

late List<CameraDescription> cameras;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await configureAmplify();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //final Future<AuthUser> _user = Amplify.Auth.getCurrentUser();
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/confirm') {
          return PageRouteBuilder(
            pageBuilder: (_,__,___) => ConfirmScreen(data: settings.arguments as LoginData),
            transitionsBuilder: (_,__,___, child) => child,
          );
        }
        if(settings.name == '/confirm-reset'){
          return PageRouteBuilder(
            pageBuilder: (_,__,___) => ConfirmResetScreen(data: settings.arguments as LoginData),
            transitionsBuilder: (_,__,___,child) => child,
          );
        }
        if (settings.name == '/dashboard') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => DashboardScreen(name: settings.arguments as String),
            transitionsBuilder: (_, __, ___, child) => child,
          );
        }
        if (settings.name == '/landscape') {
          return PageRouteBuilder(
            pageBuilder: (_,__,___) => LandscapePlayer(data: settings.arguments as List<String>,),
            transitionsBuilder: (_,__,___, child) => child,
          );
        }
        if (settings.name == '/FaceRecognition') {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => MyFace(cameras: cameras),
            transitionsBuilder: (_, __, ___, child) => child,
          );
        }
        return MaterialPageRoute(builder: (_) => EntryScreen());
      },
    );
  }
}
