import 'package:flutter/material.dart';

import '../../screens/new_password/new_password_form.dart';
import 'passwordInfo.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var cards = [
    PasswordInfo(1, 'Discord (Main)', 'T2ThatGuy', 'test@gmail.com',
        'password12345', 'discord', 'https://www.discord.com/')
  ];

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
                Navigator.pop(context);
              }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) => cardListTile(
                  cards[index].passwordName, cards[index].application),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => NewPasswordDialog(),
                fullscreenDialog: true),
          );
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

  void addNewCard() {
    cards.add(PasswordInfo(1, 'Discord (Main)', 'T2ThatGuy', 'test@gmail.com',
        'password12345', 'discord', 'https://www.discord.com/'));

    setState(() {});
  }
}
