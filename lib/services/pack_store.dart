import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 내려받은 데이터 파일을 앱 저장소에 둔다. 웹은 pack_store_web.dart.
class PackStore {
  Future<Directory> _dir() async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/packs').create(recursive: true);
  }

  /// 저장한 파일과 그 버전(tag). 없으면 null.
  Future<(String tag, String body)?> read(String name) async {
    try {
      final dir = await _dir();
      final tag = File('${dir.path}/$name.tag');
      final body = File('${dir.path}/$name.json');
      if (!await tag.exists() || !await body.exists()) return null;
      return (await tag.readAsString(), await body.readAsString());
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String name, String tag, String body) async {
    try {
      final dir = await _dir();
      await File('${dir.path}/$name.json').writeAsString(body, flush: true);
      // 본문을 다 쓴 뒤에 버전을 적어서, 중간에 끊기면 다음에 다시 받는다.
      await File('${dir.path}/$name.tag').writeAsString(tag, flush: true);
    } catch (_) {
      // 저장하지 못해도 이번 실행에서는 메모리에 있는 것을 쓴다.
    }
  }

  Future<void> delete(String name) async {
    try {
      final dir = await _dir();
      for (final ext in ['tag', 'json']) {
        final file = File('${dir.path}/$name.$ext');
        if (await file.exists()) await file.delete();
      }
    } catch (_) {
      // 지우지 못하면 다음에 받을 때 덮어쓴다.
    }
  }
}
