import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:password_manager_app/services/encrypt.dart';

import '../models/passwordInfo.dart';
import '../models/user.dart';

import 'package:http/http.dart' as http;
import 'encrypt.dart';
import 'file_handler.dart';

class APIInterface {
  final mainUrl = 'http://192.168.1.151:5000';
  final userInfo = new User();

  FileHandler fileHandler = getFileHandler();

  var cards = [];

  Map<String, String> getTokenHeader() {
    return <String, String>{'Authorization': 'Bearer ' + userInfo.getToken()};
  }

  Future<bool> login(String username, String password) async {
    Map<String, String> _headers = {
      'Authorization':
          'Basic ' + base64.encode(utf8.encode('$username:$password'))
    };

    try {
      final response = await http
          .get(Uri.parse('$mainUrl/user/login'), headers: _headers)
          .timeout(Duration(seconds: 5));

      final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        userInfo.setUserInfo(responseData["data"]["id"],
            responseData["data"]["username"], responseData["data"]["token"]);

        getEncryptionRef().generateKey(password);
        await getPasswords();

        await fileHandler.onlineLogIn(username, password, cards, applyQueue);

        return true;
      }
    } on TimeoutException catch (_) {
      print(_);
    } on SocketException catch (_) {
      print(_);
    }

    bool reponse = await fileHandler.offlineLogIn(username, password);

    if (reponse == true) {
      cards = await fileHandler.getPasswords();
    }

    return reponse;
  }

  Future<void> getPasswords() async {
    Map<String, String> _headers = getTokenHeader();

    final response = await http
        .get(Uri.parse('$mainUrl/dashboard/get-passwords'), headers: _headers);
    final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

    List<PasswordInfo> passwords = [];
    for (var i in responseData["data"]) {
      PasswordInfo password = PasswordInfo(i["uid"], i["password_name"],
          i["username"], i["password"], i["email"], i["application"], i["url"]);
      passwords.add(password);
    }

    cards = passwords;
  }

  Future<void> createNewPassword(Map<String, dynamic> password) async {
    Map<String, String> _headers = getTokenHeader();
    _headers.addAll({'Content-Type': 'application/json;charset=UTF-8'});

    Map<String, dynamic> _body = password;
    _body.addAll(<String, dynamic>{"user_id": userInfo.getUserId()});

    try {
      final response = await http
          .post(Uri.parse('$mainUrl/dashboard/create-password'),
              headers: _headers, body: jsonEncode(_body))
          .timeout(Duration(seconds: 5));

      final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

      var newPassword = PasswordInfo(
        responseData["data"]["uid"],
        responseData["data"]["password_name"],
        responseData["data"]["username"],
        responseData["data"]["password"],
        responseData["data"]["email"],
        responseData["data"]["application"],
        responseData["data"]["url"],
      );

      await fileHandler.addNewPassword(responseData["data"]);
      cards.add(newPassword);
      return;
    } on TimeoutException catch (_) {
      // Catches if the api does not respond on time
    } on SocketException catch (_) {
      // Catches if no available WiFi connection
    }

    PasswordInfo newPassword = await fileHandler.createNewPassword(password);
    cards.add(newPassword);
  }

  Future<void> deletePassword(PasswordInfo password) async {
    Map<String, String> _headers = getTokenHeader();
    _headers.addAll({'Content-Type': 'application/json;charset=UTF-8'});

    Map<String, String> _body = {'password_id': password.uid};

    try {
      final response = await http
          .delete(
            Uri.parse('$mainUrl/dashboard/del-password'),
            headers: _headers,
            body: jsonEncode(_body),
          )
          .timeout(Duration(seconds: 5));

      final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 404 || response.statusCode == 400) {
        print(responseData["message"]);
        return;
      } else if (response.statusCode == 200) {
        fileHandler.deletePassword(password.uid, addQueue: false);
        cards.remove(password);
        return;
      }
    } on TimeoutException catch (_) {
      // Catches if the api does not respond on time
    } on SocketException catch (_) {
      // Catches if no available WiFi connection
    }

    fileHandler.deletePassword(password.uid);
    cards.remove(password);
  }

  // Future<void> applyQueue() async {
  //   print('[QUEUE] Applying queue');
  //   return;
  // }

  Future<void> applyQueue(var db) async {
    List<Map> queueList = await fileHandler.getQueue(db);

    Map<String, String> _headers = getTokenHeader();
    _headers.addAll({'Content-Type': 'application/json;charset=UTF-8'});

    for (var i in queueList) {
      print(i);

      String endpoint = getEncryptionRef().decodeThis(i['endpoint']);
      String arguments = getEncryptionRef().decodeThis(i['arguments']);
      String method = getEncryptionRef().decodeThis(i['method']);

      print('Method: $method');
      print('Arguments: $arguments');
      print('Endpoint: $endpoint');

      try {
        if (method == 'POST') {
          final response = await http
              .post(
                Uri.parse('$mainUrl$endpoint'),
                headers: _headers,
                body: arguments,
              )
              .timeout(Duration(seconds: 5));

          final responseData = jsonDecode(response.body);

          if (response.statusCode == 200 || response.statusCode == 202) {
            fileHandler.removeItemFromQueue(i['id'], db);

            fileHandler.addNewPassword(responseData['data']);
            cards.add(PasswordInfo(
                responseData['data']['uid'],
                responseData['data']['password_name'],
                responseData['data']['username'],
                responseData['data']['password'],
                responseData['data']['email'],
                responseData['data']['application'],
                responseData['data']['url']));
          }
        } else if (method == 'DELETE') {
          final response = await http
              .delete(
                Uri.parse('$mainUrl$endpoint'),
                headers: _headers,
                body: arguments,
              )
              .timeout(Duration(seconds: 5));

          final responseData = jsonDecode(response.body);

          if (response.statusCode == 200 || response.statusCode == 202) {
            fileHandler.removeItemFromQueue(i['id'], db);

            fileHandler.deletePassword(responseData['data'], addQueue: false);

            var toRemove = [];
            cards.forEach((psw) {
              if (psw.uid == responseData['data']) {
                toRemove.add(psw);
              }
            });

            cards.removeWhere((psw) => toRemove.contains(psw));
          }
        }

        return;
      } on TimeoutException catch (_) {
        return;
      } on SocketException catch (_) {
        return;
      }
    }
  }
}

final _databaseInterface = APIInterface();

APIInterface getDatabaseRef() {
  return _databaseInterface;
}
