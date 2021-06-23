import 'package:flutter/material.dart';

import '../../database/database_interface.dart';
import '../../services/timer.dart';

import '../../services/encrypt.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _databaseInterface = getDatabaseRef();

  var username;
  var password;

  final usernameField = new TextEditingController();
  final passwordField = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _buildColumn(context)));
  }

  Column _buildColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: Text(
              "PASSWORD MANAGER",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 25,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: TextField(
            controller: usernameField,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter a Username',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
          child: TextField(
            controller: passwordField,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter a Password',
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(2),
            child: ElevatedButton(
              child: Text('LOGIN'),
              onPressed: () {
                performLogIn(context);
              },
            ),
          ),
        )
      ],
    );
  }

  void performLogIn(BuildContext context) async {
    username = usernameField.text;
    password = passwordField.text;

    var response = await _databaseInterface.login(username, password);

    if (response == true) {
      clearInputs();
      getTimerRef().startTimer(context);
      getEncryptionRef().generateKey(password);
      Navigator.pushNamed(context, '/dashboard');
    } else {
      print('Something went wrong!');
    }
  }

  void clearInputs() {
    username = '';
    password = '';

    usernameField.text = '';
    passwordField.text = '';

    FocusScope.of(context).unfocus(); //Hides keyboard if it is already up
  }
}
