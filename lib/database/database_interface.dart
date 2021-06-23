import 'package:http/http.dart' as http;

import '../models/passwordInfo.dart';
import '../models/user.dart';

import 'dart:convert';

class DatabaseInterface {
  final userInfo = new User();
  var cards = [];

  Map<String, String> getTokenHeader() {
    return <String, String>{'Authorization': 'Bearer ' + userInfo.getToken()};
  }

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
    Map<String, String> _headers = getTokenHeader();

    final response = await http.get(
        Uri.parse('http://192.168.1.151:5000/dashboard/get-passwords'),
        headers: _headers);

    final responseData = jsonDecode(response.body);

    List<PasswordInfo> passwords = [];

    for (var i in responseData["data"]) {
      PasswordInfo password = PasswordInfo(i["id"], i["password_name"],
          i["username"], i["password"], i["email"], i["application"], i["url"]);
      passwords.add(password);
    }

    return passwords;
  }

  Future<bool> createNewPassword(Map<String, String> password) async {
    Map<String, String> _headers = getTokenHeader();

    return true;
  }

  Future<void> deletePassword(PasswordInfo password) async {
    Map<String, String> _headers = getTokenHeader();
    _headers.addAll({'Content-Type': 'application/json;charset=UTF-8'});
    Map<String, int> _body = {'password_id': password.id};
    var _url = Uri.parse('http://192.168.1.151:5000/dashboard/del-password');

    final response = await http.delete(
      _url,
      headers: _headers,
      body: json.encode(_body),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 404 || response.statusCode == 400) {
      print(responseData["message"]);
    }

    cards.remove(password);
  }
}

final _databaseInterface = DatabaseInterface();

DatabaseInterface getDatabaseRef() {
  return _databaseInterface;
}


// TODO: Add api support for creating new password!
// TODO: Add local db support and queue system!
// TODO: COMPLETE! Add support for deleting a password!
// TODO: Add support for changing / editing a passwords information!

// TODO: Encrypt passwords allowing before sending them off to the database when creating a new password instead of storing them in plane text!