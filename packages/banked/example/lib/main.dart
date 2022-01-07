import 'package:banked/banked.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController(text: '');
  final _continueUrlController = TextEditingController(text: '');
  final _paymentIdController = TextEditingController(text: '');

  BankedResult? _bankedResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _continueUrlController.dispose();
    _paymentIdController.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final bankedResult = await Banked.startPayment(
      apiKey: _apiKeyController.text,
      continueUrl: _continueUrlController.text,
      paymentId: _paymentIdController.text,
    );

    // ignore: prefer_function_declarations_over_variables
    final newState = () {
      _bankedResult = bankedResult;
    };

    if (mounted) {
      setState(newState);
    } else {
      newState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Api key',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter api key';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _continueUrlController,
                    decoration: const InputDecoration(
                      labelText: 'continue URL',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter continue URL';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _paymentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Payment ID',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter payment ID';
                      return null;
                    },
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.white),
                      shape: MaterialStateProperty.resolveWith(
                        (states) {
                          return RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 12.0,
                            ),
                          );
                        },
                      ),
                    ),
                    onPressed: () {
                      _startPayment();
                    },
                    child: const Text('Start Payment'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith((states) => Colors.white),
                      shape: MaterialStateProperty.resolveWith(
                        (states) {
                          return RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 12.0,
                            ),
                          );
                        },
                      ),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          _bankedResult = null;
                          _apiKeyController.clear();
                          _continueUrlController.clear();
                          _paymentIdController.clear();
                        },
                      );
                    },
                    child: Text('Payment result: ${_bankedResult?.status} '),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
