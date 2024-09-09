import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluttertrans/src/html_page.dart';
import 'package:fluttertrans/src/launch_url.dart';

Future<List<String>> getStrings({
  required List<String> strings,
  required List<String> initialSelection,
}) async {
  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );
  print(
      'Head to http://${server.address.address}:${server.port} and choose all the strings to be translated.');
  await launchUrl('http://${server.address.address}:${server.port}');

  final selectedStringsCompleter = Completer<List<String>>();

  await for (HttpRequest request in server) {
    if (request.method == 'GET' && request.uri.path == '/strings') {
      handleGetStrings(request, strings);
    } else if (request.method == 'GET' &&
        request.uri.path == '/selectedStrings') {
      handleGetStrings(request, initialSelection);
    } else if (request.method == 'POST') {
      final selectedStrings = await handlePostStrings(request);
      if (selectedStrings != null) {
        await server.close(force: true);

        /// Complete the future with the selected strings
        selectedStringsCompleter.complete(selectedStrings);
      }
    } else if (request.method == 'GET' && request.uri.path == '/') {
      request.response.headers.contentType = ContentType.html;
      request.response.write(htmlPage);
      await request.response.close();
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not Found');
      await request.response.close();
    }
  }

  return selectedStringsCompleter.future;
}

// GET /strings and /selectedStrings
void handleGetStrings(HttpRequest request, List<String> strings) async {
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(strings));
  await request.response.close();
}

// POST to any path
Future<List<String>?> handlePostStrings(HttpRequest request) async {
  List<String>? selectedStrings;
  try {
    String content = await utf8.decoder.bind(request).join();
    Map<String, dynamic> data = jsonDecode(content);

    selectedStrings = List<String>.from(data['selectedStrings']);

    request.response.statusCode = HttpStatus.ok;
    request.response.write('Strings submitted successfully');
  } catch (e) {
    request.response.statusCode = HttpStatus.badRequest;
    request.response.write('Invalid request: ${e.toString()}');
  } finally {
    await request.response.close();
  }
  return selectedStrings;
}
