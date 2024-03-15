import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tugas_2_kriptografi_koding/src/extended_vigenere_cipher.dart';
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
  bool _isEncryptMode = false;

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
            ElevatedButton(
              onPressed: () async {
                if (!_isEncryptMode) {
                  _encrypt();
                } else {
                  _decrypt();
                }
                await _downloadResult();
              },
              child: Text('Download ${_isEncryptMode ? 'Decrypted' : 'Encrypted'} Text'),
            ),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? filePath =
                    await FilePicker.platform.pickFiles();
                if (filePath != null) {
                  _processFile(filePath.files.single.path!);
                }
              },
              child: const Text('Choose File'),
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
    String paddedInputText =
        _inputText.padRight((_inputText.length + 3) & ~3, 's');
    while (paddedInputText.length % 4 != 0) {
      paddedInputText += 's';
    }
    List<int> ciphertext = base64Decode(paddedInputText);
    List<int> key = utf8.encode(_key);
    ExtendedVigenereCipher extendedVigenereCipher =
        ExtendedVigenereCipher(_key);
    List<int> vigenereDecrypted = extendedVigenereCipher.decrypt(ciphertext);
    ModifiedRC4 rc4 = ModifiedRC4(key);
    List<int> plaintext = rc4.decrypt(vigenereDecrypted);
    setState(() {
      _outputText = String.fromCharCodes(plaintext);
    });
  }

  Future<void> _downloadResult() async {
    if (_outputText.isNotEmpty) {
      try {
        final String fileName =
            !_isEncryptMode ? 'encrypted_text.txt' : 'decrypted_text.txt';
        final String downloadsDirectoryPath =
            (await getDownloadsDirectory())!.path;
        final String filePath = '$downloadsDirectoryPath/$fileName';
        final File resultFile = File(filePath);
        await resultFile.writeAsString(_outputText);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('File downloaded successfully: $filePath'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to download file: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No output text available to download!'),
      ));
    }
  }

  void _processFile(String filePath) async {
    List<int> fileBytes = await File(filePath).readAsBytes();
    List<int> key = utf8.encode(_key);
    String fileName = filePath.split('/').last;
    String fileExtension = fileName.split('.').last;
    if (!_isEncryptMode) {
      ModifiedRC4 rc4 = ModifiedRC4(key);
      List<int> rc4Encrypted = rc4.encrypt(fileBytes);
      ExtendedVigenereCipher extendedVigenereCipher =
          ExtendedVigenereCipher(_key);
      List<int> vigenereEncrypted =
          extendedVigenereCipher.encrypt(rc4Encrypted);

      String downloadsDirectoryPath = '';
      final Directory? downloadsDir = await getDownloadsDirectory();
      downloadsDirectoryPath = downloadsDir!.path;

      String encryptedFilePath =
          '$downloadsDirectoryPath/${fileName}_encrypted.$fileExtension';

      await File(encryptedFilePath).writeAsBytes(vigenereEncrypted);
      setState(() {
        _outputText = 'File encrypted successfully: $encryptedFilePath';
      });
    } else {
      ExtendedVigenereCipher extendedVigenereCipher =
          ExtendedVigenereCipher(_key);
      List<int> vigenereDecrypted = extendedVigenereCipher.decrypt(fileBytes);
      ModifiedRC4 rc4 = ModifiedRC4(key);
      List<int> plaintext = rc4.decrypt(vigenereDecrypted);

      String downloadsDirectoryPath = '';
      final Directory? downloadsDir = await getDownloadsDirectory();
      downloadsDirectoryPath = downloadsDir!.path;

      String decryptedFilePath =
          '$downloadsDirectoryPath/${fileName}_decrypted.$fileExtension';

      await File(decryptedFilePath).writeAsBytes(plaintext);
      setState(() {
        _outputText = 'File decrypted successfully: $decryptedFilePath';
      });
    }
  }
}
