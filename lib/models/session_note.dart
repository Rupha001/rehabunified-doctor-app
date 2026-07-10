class SessionNote {
  final String id;
  final String patientId;
  final String content;
  final DateTime createdAt;

  SessionNote({
    required this.id,
    required this.patientId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SessionNote.fromJson(Map<String, dynamic> json) => SessionNote(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
