class Comment {
  final String text;
  final DateTime timestamp;

  Comment({
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class CapsuleEntry {
  final String id;
  final String content;
  final String? imagePath;
  final String? songInfo;
  final DateTime timestamp;
  final List<Comment> comments;

  CapsuleEntry({
    required this.id,
    required this.content,
    this.imagePath,
    this.songInfo,
    required this.timestamp,
    this.comments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'imagePath': imagePath,
      'songInfo': songInfo,
      'timestamp': timestamp.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory CapsuleEntry.fromJson(Map<String, dynamic> json) {
    return CapsuleEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      imagePath: json['imagePath'] as String?,
      songInfo: json['songInfo'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
