import 'package:flutter/material.dart';

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
                  _databaseInterface.cards[index].passwordName,
                  _databaseInterface.cards[index].application),
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

  Card cardListTile(String title, String application) {
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
          print(title);
        },
        title: Text(title),
        subtitle: Text(
          application,
          style: TextStyle(
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Color(0xBBF5FCF9)
                      : Color(0xFF000000)),
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
}
