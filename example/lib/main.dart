import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_translator/native_translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion =
          await NativeTranslator().getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  final TextEditingController _textController = TextEditingController(
    text: 'Hello, how are you?',
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Translator Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Running on: $_platformVersion\n'),
              FutureBuilder(
                future: NativeTranslator().isSupported(),
                builder: (context, snapshot) =>
                    Text('Supported: ${snapshot.data}'),
              ),

              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Text to translate',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_textController.text.isNotEmpty) {
                    try {
                      final isSupported = await NativeTranslator()
                          .isSupported();
                      if (!isSupported) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Native translation is not supported on this device.',
                            ),
                          ),
                        );
                        return;
                      }

                      await NativeTranslator().translateText(
                        text: _textController.text,
                      );
                    } catch (e, trace) {
                      if (kDebugMode) {
                        print(e);
                        print(trace);
                      }
                    }
                  }
                },
                child: const Text('Translate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
