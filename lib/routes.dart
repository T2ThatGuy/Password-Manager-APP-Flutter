import 'package:flutter/widgets.dart';

import 'screens/dashboard/dashboard.dart';
import 'screens/login/login.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/login": (BuildContext context) => LogIn(),
  "/dashboard": (BuildContext context) => Dashboard(),
};
