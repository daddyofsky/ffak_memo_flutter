import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

import '../library/config.dart';

class Crypt {
  static const int ivLength = 16;

  static Encrypter _getAes([String salt = '']) {
    if (salt == '') {
      salt = Config.key;
    }
    final Key key = Key.fromUtf8(salt.substring(0, 32));
    return Encrypter(AES(key, mode: AESMode.cbc));
  }

  static String encrypt(String plainText, [String salt = '']) {
    final Encrypter aes = _getAes(salt);
    final IV iv = IV.fromSecureRandom(ivLength);
    final Encrypted encrypted = aes.encrypt(plainText, iv: iv);

    return base64.encode(iv.bytes + encrypted.bytes);
  }

  static String decrypt(String encryptedText, [String salt = '']) {
    final Uint8List bytes = base64.decode(encryptedText);

    final Encrypter aes = _getAes(salt);
    final IV iv = IV(bytes.sublist(0, ivLength));
    final Encrypted encrypted = Encrypted(bytes.sublist(ivLength));

    return aes.decrypt(encrypted, iv: iv);
  }
}