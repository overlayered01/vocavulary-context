/// 웹은 따로 저장하지 않는다. CDN 주소가 버전마다 고정이라 브라우저 캐시가 대신한다.
class PackStore {
  Future<(String tag, String body)?> read(String name) async => null;

  Future<void> write(String name, String tag, String body) async {}

  Future<void> delete(String name) async {}
}
