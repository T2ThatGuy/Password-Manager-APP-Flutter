// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:sqflite/sqflite.dart';

// import 'package:uuid/uuid.dart';

// import '../models/passwordInfo.dart';

// import 'encrypt.dart';

// class FileHandler {
//   var _localDBExists;
//   var _database;

//   var _username;
//   var _password;

//   FileHandler() {
//     checkFiles();
//   }

//   // --- PRIVATE GETTERS ---
//   Future<String> get _databasePath async {
//     return await getDatabasesPath();
//   }

//   // Performs a check upon startup to see if the database exists or not
//   void checkFiles() async {
//     _localDBExists = await File('$_databasePath/userData.db').exists();
//   }

//   Future<bool> offlineLogIn(String username, String password) async {
//     print(_localDBExists);

//     _username = username;
//     _password = password;

//     String path = '$_databasePath/userData.db';
//     _database = await openDatabase(path);

//     List<Map> list = await _database
//         .rawQuery('SELECT * FROM user WHERE username = ?', [username]);

//     print(list);

//     if (!(list.length > 0)) {
//       return false;
//     }

//     if (HashService().checkPasswordHash(list[0]['master_password'], password)) {
//       return true;
//     }

//     return false;
//   }

//   // Ran when the users logs in via Public Database
//   Future<void> uponLogIn(String username, String password,
//       List<dynamic> passwords, Function checkQueue) async {
//     String path = '$_databasePath/userData.db';

//     // <- Use for resetting local db in during debugging

//     _database = await openDatabase(path, version: 1,
//         onCreate: (Database db, int version) {
//       generateDatabase(db, username, password, passwords);
//     }, onOpen: (Database db) async {
//       checkQueue(db);
//       await deleteDatabase(path);
//       generateDatabase(db, username, password, passwords);
//     });

//     _localDBExists = true;
//   }

//   // Generates the local database based upon the user info provided
//   void generateDatabase(Database db, String username, String password,
//       List<dynamic> passwords) async {
//     print("[FILES] - Generating Local Database");

//     await db.execute("""
//       CREATE TABLE user (
//         id INTEGER NOT NULL PRIMARY KEY,
//         username TEXT NOT NULL,
//         master_password TEXT NOT NULL
//       )
//       """);

//     await db.execute("""
//       CREATE TABLE passwords (
//         id INTEGER NOT NULL PRIMARY KEY,
//         password_name TEXT NOT NULL,
//         username TEXT NOT NULL,
//         email TEXT NOT NULL,
//         password TEXT NOT NULL,
//         application TEXT,
//         url TEXT,
//         uid TEXT NOT NULL
//       )
//       """);

//     await db.execute("""
//       CREATE TABLE queue (
//         id INTEGER NOT NULL PRIMARY KEY,
//         method TEXT NOT NULL,
//         endpoint TEXT NOT NULL,
//         arguments TEXT NOT NULL
//       )
//     """);

//     final hashedPassword = HashService().generatePasswordHash(password);

//     await db.transaction((txn) async {
//       int id = await txn.rawInsert(
//           'INSERT INTO user(username, master_password) VALUES(?, ?)',
//           [username, hashedPassword]);
//       print('[INSERT] - User at id: $id');

//       for (var i in passwords) {
//         int passwordId = await txn.rawInsert(
//           """
//           INSERT INTO passwords(password_name, username, email, password, application, url, uid) VALUES (?,?,?,?,?,?,?)
//           """,
//           [
//             i.passwordName,
//             i.username,
//             i.email,
//             i.password,
//             i.application,
//             i.url,
//             i.uid
//           ],
//         );

//         print('[INSERT] - Password (${i.passwordName}) at id: $passwordId');
//       }
//     });
//   }

//   // -- ALL OFFLINE ACTIONS -- //

//   // Get all passwords in db
//   Future<List<dynamic>> getPasswords() async {
//     List<dynamic> tempArr = [];
//     List<Map> list = await _database.rawQuery('SELECT * FROM passwords');

//     for (var i in list) {
//       tempArr.add(
//         PasswordInfo(
//           i['uid'],
//           i['password_name'],
//           i['username'],
//           i['password'],
//           i['email'],
//           i['application'],
//           i['url'],
//         ),
//       );
//     }

//     return tempArr;
//   }

//   // Add a new password
//   Future<PasswordInfo> createNewPassword(Map<String, dynamic> password) async {
//     String uniqueId = Uuid().v4();

//     await _database.transaction((txn) async {
//       int id = await txn.rawInsert(
//           'INSERT INTO passwords(password_name, username, email, password, application, url, uid) VALUES(?, ?, ?, ?, ?, ?, ?)',
//           [
//             password['password_name'],
//             password['username'],
//             password['email'],
//             password['password'],
//             password['application'],
//             password['url'],
//             uniqueId
//           ]);
//       print('[INSERT] - Password (${password['password_name']}) at id: $id');
//     });

//     password['uid'] = uniqueId;
//     addToQueue('POST', '/dashboard/create-password', password);

//     PasswordInfo newPassword = PasswordInfo(
//       uniqueId,
//       password['password_name'],
//       password['username'],
//       password['password'],
//       password['email'],
//       password['application'],
//       password['url'],
//     );

//     return newPassword;
//   }

//   // Delete a password
//   void deletePassword(String passwordId) async {
//     int count = await _database
//         .rawDelete('DELETE FROM passwords WHERE uid = ?', [passwordId]);

//     addToQueue(
//         'DELETE', '/dashboard/del-password', {'password_id': passwordId});

//     print('[DELETE] - Password deleted with id: $count');
//   }

//   // --- QUEUE SYSTEM --- //

//   // Add action to queue
//   void addToQueue(
//       String method, String endpoint, Map<dynamic, dynamic> arguments) async {
//     await _database.transaction((txn) async {
//       int id = await txn.rawInsert(
//           "INSERT INTO queue(method, endpoint, arguments) VALUES(?, ?, ?)", [
//         getEncryptionRef().encryptThis(method),
//         getEncryptionRef().encryptThis(endpoint),
//         getEncryptionRef().encryptThis(jsonEncode(arguments))
//       ]);

//       print('[INSERT] - Command added to queue at id: $id');
//     });
//   }

//   void removeItemFromQueue(int queueId) async {
//     int count =
//         await _database.rawDelete('DELETE FROM queue WHERE id = ?', [queueId]);

//     print('[DELETE] - Queue item deleted with id: $count');
//   }

//   Future<List<Map>> getQueue(Database db) async {
//     List<Map> queueList = await db.rawQuery('SELECT * FROM queue');
//     return queueList;
//   }

//   // -- PUBLIC GETTERS -- //
//   bool getLocalDBExists() {
//     return _localDBExists;
//   }

//   String getUserInfo() {
//     return '$_username:$_password';
//   }
// }

// FileHandler _fileHandler = FileHandler();

// FileHandler getFileHandler() {
//   return _fileHandler;
// }

// // Future<String> get _localPath async {
// //   final directory = await getApplicationDocumentsDirectory();
// //   return directory.path;
// // }

// // Future<File> get _localDBFile async {
// //   return File('$_localPath/userData.dat');
// // }
