// 사진 속 글자 읽기. Android·iOS는 ML Kit(기기 안에서 처리), 웹은 지원하지 않는다.
export 'text_scanner_stub.dart'
    if (dart.library.io) 'text_scanner_mlkit.dart';
