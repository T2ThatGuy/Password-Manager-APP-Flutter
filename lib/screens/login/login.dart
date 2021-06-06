import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  var username;
  var password;

  final usernameField = new TextEditingController();
  final passwordField = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _buildColumn()));
  }

  Column _buildColumn() {
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
              onPressed: performLogIn,
            ),
          ),
        )
      ],
    );
  }

  void performLogIn() {
    username = usernameField.text;
    password = passwordField.text;

    if (username == 'T2ThatGuy') {
      if (password == '12345') {
        print('Loged In');
        clearInputs();
        Navigator.pushNamed(context, '/dashboard');
      } else {
        print('Password Inorrect');
      }
    } else {
      print('Username not correct');
    }
  }

  void clearInputs() {
    username = '';
    password = '';

    usernameField.text = '';
    passwordField.text = '';
  }
}
