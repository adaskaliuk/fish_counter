import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> resolveHiveBasePath() async {
  try {
    return (await getApplicationSupportDirectory()).path;
  } catch (_) {
    return Directory.systemTemp.path;
  }
}
