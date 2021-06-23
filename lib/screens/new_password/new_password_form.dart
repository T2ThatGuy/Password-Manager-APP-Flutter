import 'dart:math';

import 'package:flutter/material.dart';

class NewPasswordDialog extends StatefulWidget {
  @override
  _NewPasswordDialogState createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<NewPasswordDialog> {
  final passwordNameCon = new TextEditingController();
  final usernameCon = new TextEditingController();
  final emailCon = new TextEditingController();
  final applicationCon = new TextEditingController();
  final urlCon = new TextEditingController();

  // Password Creation Options
  var letters = true;
  var numbers = true;
  var symbols = true;

  double passwordLength = 20;

  @override
  Widget build(BuildContext context) {
    generatePassword();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Password'),
      ),
      body: ListView(
        children: <Widget>[
          createTextField(
            Icons.person_outline,
            "Enter a Password Name",
            passwordNameCon,
          ),
          createTextField(
            Icons.person_outline,
            "Enter a Username",
            usernameCon,
          ),
          createTextField(
            Icons.email_outlined,
            "Enter a Email",
            emailCon,
          ),
          createTextField(
            Icons.apps_outlined,
            "Enter a Application",
            applicationCon,
          ),
          createTextField(
            Icons.link,
            "Enter a Url",
            urlCon,
          ),
          ListTile(
            title: Text('Include Letters?'),
            trailing: Switch(
              value: letters,
              onChanged: (bool value) {
                setState(() {
                  letters = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Include Numbers?'),
            trailing: Switch(
              value: numbers,
              onChanged: (bool value) {
                setState(() {
                  numbers = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Include Symbols?'),
            trailing: Switch(
              value: symbols,
              onChanged: (bool value) {
                setState(() {
                  symbols = value;
                });
              },
            ),
          ),
          ListTile(
            leading: Text('Length'),
            trailing: Text(passwordLength.round().toString()),
            title: Slider(
              value: passwordLength,
              min: 8,
              max: 32,
              divisions: 24,
              onChanged: (value) {
                setState(() {
                  passwordLength = value;
                });
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('CONFIRM'),
              onPressed: () {
                createPassword(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding createTextField(
      IconData icon, String labelText, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Icon(icon),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: labelText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String fetchStringConstant() {
    const CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const SYMBOLS = '!@#%^&*()_+}|{":?>"' + "'";
    const NUMBERS = '0123456789';

    String stringConstant = '';

    stringConstant += letters == true ? CHARACTERS : '';
    stringConstant += numbers == true ? NUMBERS : '';
    stringConstant += symbols == true ? SYMBOLS : '';

    return stringConstant;
  }

  String generatePassword() {
    String stringConstant = fetchStringConstant();
    String password = List.generate(
      passwordLength.toInt(),
      (index) {
        final randomIndex = Random.secure().nextInt(stringConstant.length);
        return stringConstant[randomIndex];
      },
    ).join('');

    return password;
  }

  void createPassword(BuildContext context) {
    Map<String, dynamic> _data = {
      'password_name': passwordNameCon.text,
      'username': usernameCon.text,
      'password': generatePassword(),
      'email': emailCon.text,
      'application': applicationCon.text,
      'url': urlCon.text
    };

    Navigator.pop(context, _data);
  }
}

// TODO: COMPLETED! Make the form scrollable / into a list allowing for multiple devices to support the app correctly!