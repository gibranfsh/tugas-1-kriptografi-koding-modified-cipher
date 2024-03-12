export 'ExtendedVigenereCipher.dart';

class ExtendedVigenereCipher {
  String _key;

  ExtendedVigenereCipher(this._key);

  List<int> encrypt(List<int> plaintext) {
    List<int> ciphertext = [];
    for (int i = 0; i < plaintext.length; i++) {
      int keyIndex = i % _key.length;
      int key = _key.codeUnitAt(keyIndex);
      int encryptedByte = (plaintext[i] + key) % 256;
      ciphertext.add(encryptedByte);
    }
    return ciphertext;
  }

  List<int> decrypt(List<int> ciphertext) {
    List<int> plaintext = [];
    for (int i = 0; i < ciphertext.length; i++) {
      int keyIndex = i % _key.length;
      int key = _key.codeUnitAt(keyIndex);
      int decryptedByte = (ciphertext[i] - key) % 256;
      if (decryptedByte < 0) {
        decryptedByte += 256;
      }
      plaintext.add(decryptedByte);
    }
    return plaintext;
  }
}
