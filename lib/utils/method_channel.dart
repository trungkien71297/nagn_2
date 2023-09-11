import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MethodChannelExecutor {
  static const channel = MethodChannel("nagn.peemoti.epubeditor");

  Future<void> openFile(List<String> mime) async {
    try {
      final mimes = mime.join(',');
      await channel.invokeMethod("OPEN_FILE", {'mime': mimes});
    } catch (e) {
      if (kDebugMode) {
        print('OK');
      }
    }
  }

  Future<void> saveFile(String path) async {
    try {
      await channel.invokeMethod("SAVE_FILE", {'file': path});
    } catch (e) {
      if (kDebugMode) {
        print('OK');
      }
    }
  }

  Future<String> downloadDirectory() async {
    try {
      final result = await channel.invokeMethod("GET_DOWNLOAD");
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('OK');
      }
      return "";
    }
  }
}
