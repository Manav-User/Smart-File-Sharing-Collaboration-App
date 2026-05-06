class FileVersion {
  final String id;
  final int versionNumber;
  final String description;
  final DateTime timestamp;

  FileVersion({
    required this.id,
    required this.versionNumber,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'versionNumber': versionNumber,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FileVersion.fromJson(Map<String, dynamic> json) => FileVersion(
        id: json['id'],
        versionNumber: json['versionNumber'],
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class Comment {
  final String id;
  final String text;
  final String author;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'author': author,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'],
        text: json['text'],
        author: json['author'] ?? 'User',
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class FileItem {
  final String id;
  String fileName;
  String fileType;
  String description;
  bool isShared;
  final DateTime createdAt;
  DateTime updatedAt;
  List<FileVersion> versions;
  List<Comment> comments;
  bool hasPendingSync;
  bool hasConflict;

  FileItem({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.description,
    this.isShared = false,
    required this.createdAt,
    required this.updatedAt,
    List<FileVersion>? versions,
    List<Comment>? comments,
    this.hasPendingSync = false,
    this.hasConflict = false,
  })  : versions = versions ?? [],
        comments = comments ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileType': fileType,
        'description': description,
        'isShared': isShared,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'versions': versions.map((v) => v.toJson()).toList(),
        'comments': comments.map((c) => c.toJson()).toList(),
        'hasPendingSync': hasPendingSync,
        'hasConflict': hasConflict,
      };

  factory FileItem.fromJson(Map<String, dynamic> json) => FileItem(
        id: json['id'],
        fileName: json['fileName'],
        fileType: json['fileType'],
        description: json['description'],
        isShared: json['isShared'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        versions: (json['versions'] as List?)
                ?.map((v) => FileVersion.fromJson(v))
                .toList() ??
            [],
        comments: (json['comments'] as List?)
                ?.map((c) => Comment.fromJson(c))
                .toList() ??
            [],
        hasPendingSync: json['hasPendingSync'] ?? false,
        hasConflict: json['hasConflict'] ?? false,
      );
}
