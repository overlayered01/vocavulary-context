/// 단어장 공개 범위.
enum Visibility { private, shared, public }

/// 단어장. 단어들의 묶음이며 동기화·공유의 단위.
class Wordbook {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final List<String> tags;

  /// 단어를 다시 묶는 그룹명 목록(정렬 순서 = 화면 표시 순서). 빈 그룹도 유지된다.
  final List<String> groups;
  final Visibility visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wordbook({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description = '',
    this.tags = const [],
    this.groups = const [],
    this.visibility = Visibility.private,
    required this.createdAt,
    required this.updatedAt,
  });

  Wordbook copyWith({
    String? title,
    String? description,
    List<String>? tags,
    List<String>? groups,
    Visibility? visibility,
    DateTime? updatedAt,
  }) {
    return Wordbook(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      groups: groups ?? this.groups,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'tags': tags,
    'groups': groups,
    'visibility': visibility.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Wordbook.fromMap(Map<String, dynamic> m) {
    DateTime parseDate(dynamic v) =>
        DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    return Wordbook(
      id: m['id'] as String,
      ownerId: (m['ownerId'] ?? '') as String,
      title: (m['title'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      tags: ((m['tags'] as List?) ?? []).map((e) => e.toString()).toList(),
      groups: ((m['groups'] as List?) ?? []).map((e) => e.toString()).toList(),
      visibility: Visibility.values.firstWhere(
        (v) => v.name == m['visibility'],
        orElse: () => Visibility.private,
      ),
      createdAt: parseDate(m['createdAt']),
      updatedAt: parseDate(m['updatedAt']),
    );
  }
}
