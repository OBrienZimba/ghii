class Repository {
  final int id;
  final String fullName;
  final bool private;
  final String login;
  final String avatar_url;
  final String type;
  final String description;

  Repository({
    required this.id,
    required this.fullName,
    required this.private,
    required this.login,
    required this.avatar_url,
    required this.type,
    required this.description,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      private: json['private'] ?? false,
      login: json['owner']?['login'] ?? '',
      avatar_url: json['owner']?['avatar_url'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'private': private,
      'login': login,
      'avatar_url': avatar_url,
      'type': type,
      'description': description,
    };
  }
}