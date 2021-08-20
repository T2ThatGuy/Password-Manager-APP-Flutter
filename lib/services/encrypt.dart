import 'package:encrypt/encrypt.dart';
import 'generateKey.dart' as keyCreation;

import 'package:crypt/crypt.dart';

class MyEncryption {
  final iv = IV.fromLength(16);
  var key;

  void generateKey(String password) {
    key = Key.fromUtf8(keyCreation.generateKey(password));
  }

  String encryptThis(String text) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);

    return encrypted.base64;
  }

  String decodeThis(String text) {
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(text), iv: iv);

    return decrypted;
  }
}

class HashService {
  String generatePasswordHash(String password) {
    return Crypt.sha256(password).toString();
  }

  bool checkPasswordHash(String hashedPassword, String password) {
    final hash = Crypt(hashedPassword);

    if (hash.match(password)) {
      return true;
    }

    return false;
  }
}

// void test() {
//   final plainText = 'Sample Text';
//   final key = Key.fromUtf8("hjvejk'#;123ASDkjhrt=Password723");
//   final iv = IV.fromLength(16);

//   final encrypter = Encrypter(AES(key));

//   final encrypted = encrypter.encrypt(plainText, iv: iv);

//   final encryptedBase = encrypted.base64;

//   final decrypted =
//       encrypter.decrypt(Encrypted.fromBase64(encryptedBase), iv: iv);

//   print(encrypted.base64);
//   print(decrypted);
// }

MyEncryption __encrypt = MyEncryption();

MyEncryption getEncryptionRef() {
  return __encrypt;
}
