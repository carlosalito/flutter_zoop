import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class FlutterzoopUtils {
  
  /// Método para recuperação do diretório de downloads
  Future<String> getDownloadDirectoryPath() async {
    return await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }

  /// Método para recuperação do arquivo de histórico
  Future<File> getPinpadHistoryFile() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getDownloadDirectoryPath();
      return File("$directory/pinpadHistoryData.txt");
    } else {
      print(
          "Sem permissão para acesso ao diretório de salvamento do arquivo de texto");
      return null;
    }
  }

  /// Método para salvamento dos dados de histórico
  Future<File> savePinpadHistoryData(String data) async {
    int attempts = 0;

    while (attempts < 4) {
      try {
        final file = await getPinpadHistoryFile();

        await file.writeAsString('\n\n${DateTime.now()} -- $data',
            mode: FileMode.append);

      } catch (e) {
        attempts++;
        if (attempts >= 4) {
          return null;
        }
      }
    }
    return null;
  }

}
