import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tugas_2_kriptografi_koding/src/ExtendedVigenereCipher.dart';
import 'package:tugas_2_kriptografi_koding/src/rc4.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RC4 & Vigenere Cipher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EncryptionScreen(),
    );
  }
}

class EncryptionScreen extends StatefulWidget {
  @override
  _EncryptionScreenState createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  String _inputText = '';
  String _outputText = '';
  String _key = '';
  bool _isEncryptMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RC4 & Vigenere Cipher'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Input Text',
              ),
              onChanged: (text) {
                setState(() {
                  _inputText = text;
                });
              },
            ),
            SizedBox(height: 20.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Key',
              ),
              onChanged: (text) {
                setState(() {
                  _key = text;
                });
              },
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Encrypt'),
                Switch(
                  value: _isEncryptMode,
                  onChanged: (value) {
                    setState(() {
                      _isEncryptMode = value;
                    });
                  },
                ),
                Text('Decrypt'),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (!_isEncryptMode) {
                  _encrypt();
                } else {
                  _decrypt();
                }
              },
              child: Text(!_isEncryptMode ? 'Encrypt' : 'Decrypt'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Output Text: $_outputText',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  void _encrypt() {
    List<int> plaintext = utf8.encode(_inputText);
    List<int> key = utf8.encode(_key);
    ModifiedRC4 rc4 = ModifiedRC4(key);
    List<int> rc4Encrypted = rc4.encrypt(plaintext);
    ExtendedVigenereCipher extendedVigenereCipher = ExtendedVigenereCipher(_key);
    List<int> vigenereEncrypted = extendedVigenereCipher.encrypt(rc4Encrypted);
    setState(() {
      _outputText = base64Encode(vigenereEncrypted);
    });
  }

  void _decrypt() {
    List<int> ciphertext = base64Decode(_inputText);
    List<int> key = utf8.encode(_key);
    ExtendedVigenereCipher extendedVigenereCipher = ExtendedVigenereCipher(_key);
    List<int> vigenereDecrypted = extendedVigenereCipher.decrypt(ciphertext);
    ModifiedRC4 rc4 = ModifiedRC4(key);
    List<int> plaintext = rc4.decrypt(vigenereDecrypted);
    setState(() {
      _outputText = utf8.decode(plaintext);
    });
  }
}
