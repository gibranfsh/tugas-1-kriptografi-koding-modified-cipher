export 'rc4.dart';
class ModifiedRC4 {
  final List<int> _key;
  late List<int> _state;

  int _i = 0;
  int _j = 0;

ModifiedRC4(this._key) {
  _state = List<int>.generate(256, (i) => i);
  int j = 0;
  if (_key.isNotEmpty) {
    for (int i = 0; i < 256; i++) {
      j = (j + _state[i] + _key[i % _key.length]) % 256;
      _swap(i, j);
    }
  }
}

  void _swap(int i, int j) {
    int temp = _state[i];
    _state[i] = _state[j];
    _state[j] = temp;
  }

  int _generateKeyStream() {
    _i = (_i + 1) % 256;
    _j = (_j + _state[_i]) % 256;
    _swap(_i, _j);
    return _state[(_state[_i] + _state[_j]) % 256];
  }

  List<int> encrypt(List<int> plaintext) {
    List<int> ciphertext = [];
    for (int i = 0; i < plaintext.length; i++) {
      int keystream = _generateKeyStream();
      ciphertext.add(plaintext[i] ^ keystream);
    }
    return ciphertext;
  }

  List<int> decrypt(List<int> ciphertext) {
    return encrypt(ciphertext);
  }
}
