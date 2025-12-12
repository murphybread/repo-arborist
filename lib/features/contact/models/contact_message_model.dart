/// Contact message type enum
enum ContactType {
  /// Bug fix request
  bug,

  /// Feature request
  feature,

  /// UI/UX improvement
  uiux,

  /// Other inquiries
  other,
}

/// Extension to provide display labels and conversion methods
extension ContactTypeExtension on ContactType {
  /// Get translation key for this contact type
  String get translationKey {
    switch (this) {
      case ContactType.bug:
        return 'contact.type_bug';
      case ContactType.feature:
        return 'contact.type_feature';
      case ContactType.uiux:
        return 'contact.type_uiux';
      case ContactType.other:
        return 'contact.type_other';
    }
  }

  /// Convert to string for Firestore storage
  String toJson() {
    return name;
  }

  /// Create from string stored in Firestore
  static ContactType fromJson(String value) {
    return ContactType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContactType.other,
    );
  }
}

/// Contact message data model
class ContactMessageModel {
  /// Constructor
  const ContactMessageModel({
    required this.patOwner,
    required this.repositoryOwner,
    required this.name,
    required this.content,
    required this.timestamp,
    this.type,
  });

  /// Create from Firestore JSON
  factory ContactMessageModel.fromJson(Map<String, dynamic> json) {
    return ContactMessageModel(
      patOwner: json['patOwner'] as String,
      repositoryOwner: json['repositoryOwner'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] != null
          ? ContactTypeExtension.fromJson(json['type'] as String)
          : null,
    );
  }

  /// PAT owner username (who is logged in)
  final String patOwner;

  /// Repository owner username (currently viewing)
  final String repositoryOwner;

  /// User-provided name (from form input)
  final String name;

  /// Message content
  final String content;

  /// Submission timestamp
  final DateTime timestamp;

  /// Optional contact type
  final ContactType? type;

  /// Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'patOwner': patOwner,
      'repositoryOwner': repositoryOwner,
      'name': name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (type != null) 'type': type!.toJson(),
    };
  }
}
