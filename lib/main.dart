import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tugas_2_kriptografi_koding/src/ExtendedVigenereCipher.dart';
import 'package:tugas_2_kriptografi_koding/src/rc4.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RC4 & Vigenere Cipher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EncryptionScreen(),
    );
  }
}

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        title: const Text('RC4 & Extended Vigenere Cipher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Input Text',
              ),
              onChanged: (text) {
                setState(() {
                  _inputText = text;
                });
              },
            ),
            const SizedBox(height: 20.0),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Key',
              ),
              onChanged: (text) {
                setState(() {
                  _key = text;
                });
              },
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Encrypt'),
                Switch(
                  value: _isEncryptMode,
                  onChanged: (value) {
                    setState(() {
                      _isEncryptMode = value;
                    });
                  },
                ),
                const Text('Decrypt'),
              ],
            ),
            const SizedBox(height: 20.0),
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
            const SizedBox(height: 20.0),
            Text(
              'Output Text: $_outputText',
              style: const TextStyle(fontSize: 16.0),
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
    ExtendedVigenereCipher extendedVigenereCipher =
        ExtendedVigenereCipher(_key);
    List<int> vigenereEncrypted = extendedVigenereCipher.encrypt(rc4Encrypted);
    setState(() {
      _outputText = base64Encode(vigenereEncrypted);
    });
  }

  void _decrypt() {
    List<int> ciphertext = base64Decode(_inputText);
    List<int> key = utf8.encode(_key);
    ExtendedVigenereCipher extendedVigenereCipher =
        ExtendedVigenereCipher(_key);
    List<int> vigenereDecrypted = extendedVigenereCipher.decrypt(ciphertext);
    ModifiedRC4 rc4 = ModifiedRC4(key);
    List<int> plaintext = rc4.decrypt(vigenereDecrypted);
    setState(() {
      _outputText = utf8.decode(plaintext);
    });
  }
}
