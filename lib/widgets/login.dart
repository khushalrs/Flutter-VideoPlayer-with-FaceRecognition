import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_login/flutter_login.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late LoginData _data;
  bool _isSignedIn = false;

  Future<String?> _onLogin(LoginData data) async {
    try {
      String userName = data.name;
      if(userName.contains('@gmail.com') || userName.contains('@nmims.edu.in')) {
        final res = await Amplify.Auth.signIn(
          username: data.name,
          password: data.password,
        );
        _data = data;
        _isSignedIn = res.isSignedIn;
      }
      else{
        return "Enter correct Email address";
      }
    } on AuthException catch (e) {
      if (e.message.contains('already a user which is signed in')) {
        await Amplify.Auth.signOut();
        return 'Problem logging in. Please try again.';
      }

      return '${e.message} - ${e.recoverySuggestion}';
    }
  }

  Future<String?> _onRecoverPassword(String email) async {
    try {
      final res = await Amplify.Auth.resetPassword(username: email);

      if (res.nextStep.updateStep == 'CONFIRM_RESET_PASSWORD_WITH_CODE') {
        Navigator.of(context).pushReplacementNamed(
          '/confirm-reset',
          arguments: LoginData(name: email, password: ''),
        );
      }
    } on AuthException catch (e) {
      return '${e.message} - ${e.recoverySuggestion}';
    }
  }

  Future<String?> _onSignup(SignupData data) async {
    try {
      String userName = data.name!;
      if(userName.contains('@gmail.com') || userName.contains('@nmims.edu.in')) {
        await Amplify.Auth.signUp(
          username: data.name!,
          password: data.password!,
          options: CognitoSignUpOptions(userAttributes: {
            CognitoUserAttributeKey.email: data.name!,
          }),
        );
      }
      else{
        return "Enter correct Email address";
      }

      _data = LoginData(name: data.name!, password: data.password!);
    } on AuthException catch (e) {
      return '${e.message} - ${e.recoverySuggestion}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Welcome',
      onLogin: _onLogin,
      onRecoverPassword: _onRecoverPassword,
      onSignup: _onSignup,
      theme: LoginTheme(
        primaryColor: Theme.of(context).primaryColor,
      ),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(
          _isSignedIn ? '/FaceRecognition' : '/confirm',
          arguments: _data,
        );
      },
    );
  }
}