import 'package:http/http.dart' as http;

import '../models/passwordInfo.dart';
import '../models/user.dart';

import 'dart:convert';

class DatabaseInterface {
  final userInfo = new User();
  var cards = [];

  Future<bool> login(String username, password) async {
    Map<String, String> _headers = {
      'Authorization':
          'Basic ' + base64.encode(utf8.encode('$username:$password'))
    };

    final response = await http.get(
        Uri.parse('http://192.168.1.151:5000/user/login'),
        headers: _headers);
    final responseData = jsonDecode(response.body);

    print(response.statusCode);

    if (response.statusCode == 200) {
      userInfo.setUserInfo(
          responseData["data"]["username"], responseData["data"]["token"]);

      cards = await getPasswords();

      return true;
    }
    return false;
  }

  Future<List> getPasswords() async {
    Map<String, String> _headers = {
      'Authorization': 'Bearer ' + userInfo.getToken()
    };

    final response = await http.get(
        Uri.parse('http://192.168.1.151:5000/dashboard/get-passwords'),
        headers: _headers);

    final responseData = jsonDecode(response.body);

    List<PasswordInfo> passwords = [];

    for (var i in responseData["data"]) {
      PasswordInfo password = PasswordInfo(i["password_name"], i["username"],
          i["password"], i["email"], i["application"], i["url"]);
      passwords.add(password);
    }

    return passwords;
  }

  Future<bool> createNewPassword(PasswordInfo password) async {
    Map<String, String> _headers = {
      'Authorization': 'Bearer ' + userInfo.getToken()
    };

    cards.add(password);

    return true;
  }
}

final _databaseInterface = DatabaseInterface();

DatabaseInterface getDatabaseRef() {
  return _databaseInterface;
}


// TODO: Add api support for creating new password!
// TODO: Add local db support and queue system!
// TODO: Add support for deleting a password!
// TODO: Add support for changing / editing a passwords information!

// TODO: Encrypt passwords allowing before sending them off to the database when creating a new password instead of storing them in plane text!