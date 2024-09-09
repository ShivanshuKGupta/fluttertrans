import "dart:io";

Future<bool> launchUrl(String url) async {
  ProcessResult? result;
  try {
    switch (Platform.operatingSystem) {
      case "linux":
        result = await Process.run("x-www-browser", [url]);
        break;
      case "macos":
        result = await Process.run("open", [url]);
        break;
      case "windows":
        result = await Process.run("explorer", [url]);
        break;
      default:
        break;
    }
  } catch (e) {
    return false;
  }

  return result?.exitCode == 0;
}
