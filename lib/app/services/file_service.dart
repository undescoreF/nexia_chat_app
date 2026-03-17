import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileService {
  Future<void> openDocumentFile({
    required String filePathOrUrl,
    required String fileName,
  }) async {
    try {
      String localPath;
      if (_isLocal(filePathOrUrl)) {
        localPath = filePathOrUrl;
      } else {
        localPath = await _downloadFileFromFirebase(filePathOrUrl, fileName);
      }

      final result = await OpenFile.open(localPath);

      if (result.type == ResultType.noAppToOpen) {
        debugPrint("Aucune application pour ouvrir ce fichier");
      }
    } catch (e) {
      debugPrint("Erreur lors de l'ouverture du fichier : $e");
    }
  }

  bool _isLocal(String path) {
    return path.startsWith('/') || path.startsWith('file://');
  }

  Future<String> _downloadFileFromFirebase(String url, String fileName) async {
    final ref = FirebaseStorage.instance.refFromURL(url);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await ref.writeToFile(file);
    return file.path;
  }
}
