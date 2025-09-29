import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:conecta_app/features/home/domain/entities/media_item.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(Dio());
});

class DownloadService {
  DownloadService(this._dio);

  final Dio _dio;

  Future<File> downloadMedia(MediaItem item) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${item.id}.mp3');
    if (await file.exists()) {
      return file;
    }

    final response = await _dio.get<List<int>>(
      'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
      options: Options(responseType: ResponseType.bytes),
    );
    await file.writeAsBytes(response.data ?? []);
    return file;
  }
}
