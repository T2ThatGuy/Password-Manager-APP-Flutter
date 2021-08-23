import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:uuid/uuid.dart';

import '../models/passwordInfo.dart';

import 'encrypt.dart';

class FileHandler {
  var _database;

  // --- PRIVATE GETTERS ---
  Future<String> get _databasePath async {
    return await getDatabasesPath();
  }

  Future<bool> offlineLogIn(String username, String password) async {
    String path = '$_databasePath/userData.db';
    bool _localDBFound = false;
    bool _canLogIn = false;

    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await deleteDatabase(path);
    }, onOpen: (Database db) async {
      _localDBFound = true;

      List<Map> responseList = await db
          .rawQuery('SELECT * FROM user WHERE username = ?', [username]);

      // print(responseList);

      if (!(responseList.length > 0)) {
        return;
      }

      if (HashService()
          .checkPasswordHash(responseList[0]['master_password'], password)) {
        _canLogIn = true;
        return;
      }
    });

    if (_localDBFound == false) {
      return false;
    }

    if (_canLogIn == true) {
      getEncryptionRef().generateKey(password);
      return true;
    }

    return false;
  }

  Future<void> onlineLogIn(String username, String password,
      List<dynamic> passwords, Function applyQueue) async {
    String path = '$_databasePath/userData.db';
    bool _justCreated = false;

    // await deleteDatabase(path); <--- DEBUG ONLY TO RESET LOCAL DB

    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) {
      generateNewDatabase(db, username, password, passwords);
      _justCreated = true;
    }, onOpen: (Database db) async {
      if (_justCreated == true) {
        return;
      }
      print('[DATABASE] Database opened again');
    });

    await syncDatabase(_database, username, password, passwords, applyQueue);
  }

  Future<void> syncDatabase(Database db, String username, String password,
      List<dynamic> passwords, Function applyQueue) async {
    print('[DATABASE] Syncing database');

    await applyQueue(db);

    await db.execute('DELETE FROM user');
    await db.execute('DELETE FROM passwords');
    await db.execute('DELETE FROM queue');

    addDefaultElementsToDatabase(db, username, password, passwords);
    return;
  }

  void addDefaultElementsToDatabase(Database db, String username,
      String password, List<dynamic> passwords) async {
    final hashedPassword = HashService().generatePasswordHash(password);

    await db.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO user(username, master_password) VALUES(?, ?)',
          [username, hashedPassword]);
      print('[INSERT] - User at id: $id');

      for (var i in passwords) {
        int passwordId = await txn.rawInsert(
          'INSERT INTO passwords(password_name, username, email, password, application, url, uid) VALUES (?,?,?,?,?,?,?)',
          [
            i.passwordName,
            i.username,
            i.email,
            i.password,
            i.application,
            i.url,
            i.uid
          ],
        );

        print('[INSERT] - Password (${i.passwordName}) at id: $passwordId');
      }
    });
  }

  void generateNewDatabase(Database db, String username, String password,
      List<dynamic> passwords) async {
    print("[FILE] - Generating Local Databsae");

    await db.execute("""
    CREATE TABLE user (
      id INTEGER NOT NULL PRIMARY KEY,
      username TEXT NOT NULL,
      master_password TEXT NOT NULL
    )
    """);

    await db.execute("""
    CREATE TABLE passwords (
      id INTEGER NOT NULL PRIMARY KEY,
      password_name TEXT NOT NULL,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      application TEXT,
      url TEXT,
      uid TEXT NOT NULL
    )
    """);

    await db.execute("""
    CREATE TABLE queue (
      id INTEGER NOT NULL PRIMARY KEY,
      method TEXT NOT NULL,
      endpoint TEXT NOT NULL,
      arguments TEXT NOT NULL
    )
    """);

    addDefaultElementsToDatabase(db, username, password, passwords);
  }

  Future<List<dynamic>> getPasswords() async {
    List<dynamic> tempArr = [];
    List<Map> list = await _database.rawQuery('SELECT * FROM passwords');

    for (var i in list) {
      tempArr.add(
        PasswordInfo(
          i['uid'],
          i['password_name'],
          i['username'],
          i['password'],
          i['email'],
          i['application'],
          i['url'],
        ),
      );
    }

    return tempArr;
  }

  Future<PasswordInfo> createNewPassword(Map<String, dynamic> password) async {
    String uniqueId = Uuid().v4();
    password['uid'] = uniqueId;

    await addNewPassword(password);

    await addToQueue('POST', '/dashboard/create-password', password);

    PasswordInfo newPassword = PasswordInfo(
      uniqueId,
      password['password_name'],
      password['username'],
      password['password'],
      password['email'],
      password['application'],
      password['url'],
    );

    return newPassword;
  }

  Future<void> addNewPassword(Map<String, dynamic> password) async {
    await _database.transaction((txn) async {
      int passwordId = await txn.rawInsert(
        'INSERT INTO passwords(password_name, username, email, password, application, url, uid) VALUES (?,?,?,?,?,?,?)',
        [
          password['password_name'],
          password['username'],
          password['email'],
          password['password'],
          password['application'],
          password['url'],
          password['uid']
        ],
      );

      print(
          '[INSERT] - Password (${password["password_name"]}) at id: $passwordId');
    });
  }

  void deletePassword(String passwordId, {bool addQueue = true}) async {
    await _database
        .rawDelete('DELETE FROM passwords WHERE uid = ?', [passwordId]);

    if (addQueue) {
      addToQueue(
          'DELETE', '/dashboard/del-password', {'password_id': passwordId});
    }

    print('[DELETE] - Password deleted with id: $passwordId');
  }

  // --- QUEUE SYSTEM --- //

  // Add action to queue
  Future<void> addToQueue(
      String method, String endpoint, Map<dynamic, dynamic> arguments) async {
    await _database.transaction((txn) async {
      int id = await txn.rawInsert(
          "INSERT INTO queue(method, endpoint, arguments) VALUES(?, ?, ?)", [
        getEncryptionRef().encryptThis(method),
        getEncryptionRef().encryptThis(endpoint),
        getEncryptionRef().encryptThis(jsonEncode(arguments))
      ]);

      print('[INSERT] - Command added to queue at id: $id');
    });
  }

  void removeItemFromQueue(int queueId) async {
    int count =
        await _database.rawDelete('DELETE FROM queue WHERE id = ?', [queueId]);

    print('[DELETE] - Queue item deleted with id: $count');
  }

  Future<List<Map>> getQueue(Database db) async {
    List<Map> queueList = await db.rawQuery('SELECT * FROM queue');
    // print("Queue list: $queueList");
    return queueList;
  }
}

FileHandler _fileHandler = FileHandler();

FileHandler getFileHandler() {
  return _fileHandler;
}
