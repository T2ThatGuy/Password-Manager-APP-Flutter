import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      routes: routes,
      initialRoute: '/login',
    );
  }
}


// TODO: COMPLETE! Auto logout after 10 minutes or when user is required to authenticate themselves for a valid JWT again!