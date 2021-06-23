import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager_app/models/passwordInfo.dart';

import '../new_password/new_password_form.dart';
import '../../database/database_interface.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _databaseInterface = getDatabaseRef();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Screen'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                logout(context);
              }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _databaseInterface.cards.length,
              itemBuilder: (context, index) => cardListTile(
                context,
                _databaseInterface.cards[index],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewPassword(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Card cardListTile(BuildContext content, PasswordInfo password) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      elevation: 8,
      child: ListTile(
        onTap: () {
          copyToClipboard(content, password.password);
        },
        title: Text(password.passwordName),
        subtitle: Text(
          password.application,
          style: TextStyle(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Color(0xBBF5FCF9)
                      : Color(0xFF000000)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            displayPasswordInfo(context, password);
            setState(() {});
          },
        ),
      ),
    );
  }

  void logout(BuildContext context) {
    _databaseInterface.userInfo.logOut();
    Navigator.pop(context);
  }

  void createNewPassword(BuildContext context) async {
    // Returns the PasswordInfo Class
    final information = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => NewPasswordDialog(),
          fullscreenDialog: true),
    );

    if (information != null) {
      _databaseInterface.createNewPassword(information);
      setState(() {});
    }
  }

  void copyToClipboard(BuildContext context, String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Password copied to Clipboard')));
  }

  void displayPasswordInfo(BuildContext context, PasswordInfo password) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(password.passwordName),
          content: getPasswordContent(password),
          actions: <Widget>[
            TextButton(
              child: Text('delete'),
              onPressed: () async {
                await _databaseInterface.deletePassword(password);
                setState(() {});

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('close'),
            ),
          ],
        );
      },
    );
  }

  SingleChildScrollView getPasswordContent(PasswordInfo password) {
    return SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text('Username: ' + password.username),
          Text('Password: ' + password.password),
          Text('Email: ' + password.email),
          Text('Application: ' + password.application),
          Text('URL: ' + password.url)
        ],
      ),
    );
  }
}


// TODO: COMPLETE! Add availability to click on listtile and copy it to the clipboard!
// TODO: Add availability to view the details of a password (<= Completed) and edit / delete them if necessary!
// TODO: Add encryption to copying the password