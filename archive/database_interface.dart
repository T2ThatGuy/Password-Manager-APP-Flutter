// import 'dart:async';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// import '../models/passwordInfo.dart';
// import '../models/user.dart';

// import 'dart:convert';

// import 'file_handler.dart';
// import 'encrypt.dart';

// class DatabaseInterface {
//   final mainUrl = 'http://192.168.1.151:5000';
//   final userInfo = new User();

//   FileHandler fileHandler = getFileHandler();

//   var cards = [];
//   bool _connection = false;

//   Map<String, String> getTokenHeader() {
//     return <String, String>{'Authorization': 'Bearer ' + userInfo.getToken()};
//   }

//   Future<bool> login(String username, password) async {
//     Map<String, String> _headers = {
//       'Authorization':
//           'Basic ' + base64.encode(utf8.encode('$username:$password'))
//     };
//     try {
//       final response = await http
//           .get(Uri.parse('$mainUrl/user/login'), headers: _headers)
//           .timeout(Duration(seconds: 5));

//       final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         userInfo.setUserInfo(responseData["data"]["id"],
//             responseData["data"]["username"], responseData["data"]["token"]);

//         getEncryptionRef().generateKey(password);
//         await fileHandler.uponLogIn(username, password, cards, applyQueue);

//         cards = await getPasswords();

//         _connection = true;

//         return true;
//       }
//     } on TimeoutException catch (_) {
//       // Call timedout
//       final response = await fileHandler.offlineLogIn(username, password);

//       if (response) {
//         getEncryptionRef().generateKey(password);
//         cards = await fileHandler.getPasswords();
//       }

//       return response;
//     } on SocketException catch (_) {
//       // Other exception
//       final response = await fileHandler.offlineLogIn(username, password);

//       if (response) {
//         getEncryptionRef().generateKey(password);
//         cards = await fileHandler.getPasswords();
//       }

//       return response;
//     }

//     return false;
//   }

//   Future<List> getPasswords() async {
//     Map<String, String> _headers = getTokenHeader();

//     final response = await http
//         .get(Uri.parse('$mainUrl/dashboard/get-passwords'), headers: _headers)
//         .timeout(Duration(seconds: 5));

//     final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

//     List<PasswordInfo> passwords = [];

//     for (var i in responseData["data"]) {
//       PasswordInfo password = PasswordInfo(i["uid"], i["password_name"],
//           i["username"], i["password"], i["email"], i["application"], i["url"]);
//       passwords.add(password);
//     }

//     return passwords;
//   }

//   Future<void> createNewPassword(Map<String, dynamic> password) async {
//     Map<String, String> _headers = getTokenHeader();
//     _headers.addAll({'Content-Type': 'application/json;charset=UTF-8'});
//     Map<String, dynamic> _body = password;
//     _body.addAll(<String, dynamic>{"user_id": userInfo.getUserId()});

//     if (_connection == false) {
//       PasswordInfo newPassword = await fileHandler.createNewPassword(password);
//       cards.add(newPassword);

//       return;
//     }

//     try {
//       final response = await http
//           .post(
//             Uri.parse('$mainUrl/dashboard/create-password'),
//             headers: _headers,
//             body: json.encode(_body),
//           )
//           .timeout(Duration(seconds: 5));

//       final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

//       var newPassword = PasswordInfo(
//         responseData["data"]["uid"],
//         responseData["data"]["password_name"],
//         responseData["data"]["username"],
//         responseData["data"]["password"],
//         responseData["data"]["email"],
//         responseData["data"]["application"],
//         responseData["data"]["url"],
//       );
//       cards.add(newPassword);

//       return;
//     } on TimeoutException catch (_) {
//       print('Connection timed out');
//     } on SocketException catch (_) {
//       print('[API ERROR] - Unable to connect to API');
//     }

//     _connection = false;
//     PasswordInfo newPassword = await fileHandler.createNewPassword(password);
//     cards.add(newPassword);
//   }

//   Future<void> deletePassword(PasswordInfo password) async {
//     Map<String, String> _headers = getTokenHeader();
//     _headers.addAll({'Content-Type': 'application/json;charset=UTF-8'});
//     Map<String, String> _body = {'password_id': password.uid};

//     if (_connection == false) {
//       fileHandler.deletePassword(password.uid);
//       return;
//     }

//     try {
//       final response = await http
//           .delete(
//             Uri.parse('$mainUrl/dashboard/del-password'),
//             headers: _headers,
//             body: json.encode(_body),
//           )
//           .timeout(Duration(seconds: 5));

//       final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

//       if (response.statusCode == 404 || response.statusCode == 400) {
//         print(responseData["message"]);
//         return;
//       }
//     } on TimeoutException {
//       print('Connection timed out');
//     } on SocketException catch (_) {
//       print('[API ERROR] - Unable to connect to API');
//     }

//     _connection = false;
//     fileHandler.deletePassword(password.uid);
//     cards.remove(password);
//   }

//   Future<void> applyQueue(var db) async {
//     List<Map> queueList = await fileHandler.getQueue(db);

//     if (queueList.length == 0) {
//       return;
//     }

//     Map<String, String> _headers = getTokenHeader();

//     for (var i in queueList) {
//       print(i);

//       String endpoint = getEncryptionRef().decodeThis(i['endpoint']);
//       String arguments = getEncryptionRef().decodeThis(i['arguments']);
//       String method = getEncryptionRef().decodeThis(i['method']);

//       try {
//         if (method == 'POST') {
//           _headers.addAll({'Content-Type': 'application/json;charset=UTF-8'});
//           print('Method: $method');
//           print('Arguments: $arguments');
//           print('Endpoint: $endpoint');

//           final response = await http
//               .post(
//                 Uri.parse('$mainUrl$endpoint'),
//                 headers: _headers,
//                 body: arguments,
//               )
//               .timeout(Duration(seconds: 5));

//           print(response.body);

//           if (response.statusCode == 200 || response.statusCode == 202) {
//             fileHandler.removeItemFromQueue(i['id']);
//           }
//           _headers.remove('Content-Type');
//         } else if (method == 'DELETE') {
//           final response = await http
//               .delete(
//                 Uri.parse('$mainUrl$endpoint'),
//                 headers: _headers,
//                 body: arguments,
//               )8
//               .timeout(Duration(seconds: 5));

//           print(jsonDecode(response.body));

//           if (response.statusCode == 200 || response.statusCode == 202) {
//             fileHandler.removeItemFromQueue(i['id']);
//           }
//         }

//         return;
//       } on TimeoutException catch (_) {
//         _connection = false;
//         return;
//       } on SocketException catch (_) {
//         _connection = false;
//         return;
//       }
//     }
//   }

//   // void retryLogIn() async {
//   //   Map<String, String> _headers = {
//   //     'Authorization':
//   //         'Basic ' + base64.encode(utf8.encode(fileHandler.getUserInfo()))
//   //   };

//   //   try {
//   //     final response = await http
//   //         .get(Uri.parse('$mainUrl/user/login'), headers: _headers)
//   //         .timeout(Duration(seconds: 5));

//   //     final Map<dynamic, dynamic> responseData = jsonDecode(response.body);

//   //     if (response.statusCode == 200) {
//   //       userInfo.setUserInfo(responseData["data"]["id"],
//   //           responseData["data"]["username"], responseData["data"]["token"]);

//   //       applyQueue();
//   //     }

//   //     return;
//   //   } on TimeoutException catch (_) {
//   //     return;
//   //   } on SocketException catch (_) {
//   //     return;
//   //   }
//   // }
// }

// final _databaseInterface = DatabaseInterface();

// DatabaseInterface getDatabaseRef() {
//   return _databaseInterface;
// }


// // TODO: COMPLETE! Add api support for creating new password!
// // TODO: Add local db support and queue system!
// // TODO: COMPLETE! Add support for deleting a password!
// // TODO: Add support for changing / editing a passwords information!

// // TODO: COMPLETE! Encrypt passwords allowing before sending them off to the database when creating a new password instead of storing them in plane text!