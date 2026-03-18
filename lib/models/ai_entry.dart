import 'package:uuid/uuid.dart';
import 'capsule_entry.dart'; // for Comment

enum AiEntryType {
  recall,
  summary,
}

class AiEntry {
  final String id;
  final String question;
  final String answer;
  final AiEntryType type;
  final DateTime timestamp;
  final List<Comment> comments;

  AiEntry({
    required this.id,
    required this.question,
    required this.answer,
    required this.type,
    required this.timestamp,
    this.comments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'type': type.toString().split('.').last, // Just the string enum part
      'timestamp': timestamp.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory AiEntry.fromJson(Map<String, dynamic> json) {
    return AiEntry(
      id: json['id'] as String? ?? const Uuid().v4(),
      question: json['question'] as String,
      answer: json['answer'] as String,
      type: AiEntryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AiEntryType.recall,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
