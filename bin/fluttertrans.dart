import 'dart:io';

import 'package:fluttertrans/fluttertrans.dart' as fluttertrans;

void main(List<String> arguments) async {
  try {
    await fluttertrans.main(arguments);
  } catch (e) {
    print(e);
    exit(1);
  }
}
