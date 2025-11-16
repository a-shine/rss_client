/// Postgres write model representing user-writable fields for a feed URL
class FeedUrlPostgresWriteModel {
  static const String tableName = 'feed_urls';
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnUrl = 'url';
  static const String columnName = 'name';

  final String id;
  final String userId;
  final String url;
  final String name;

  FeedUrlPostgresWriteModel({
    required this.id,
    required this.userId,
    required this.url,
    required this.name,
  });

  /// Convert write model to database map for insert/update operations
  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnUserId: userId,
      columnUrl: url,
      columnName: name,
    };
  }
}

/// Postgres read model representing a complete feed URL row from Supabase
/// Includes system-managed fields like created_at and updated_at
class FeedUrlPostgresReadModel {
  static const String tableName = 'feed_urls';
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnUrl = 'url';
  static const String columnName = 'name';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  final String id;
  final String userId;
  final String url;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedUrlPostgresReadModel({
    required this.id,
    required this.userId,
    required this.url,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from database map to read model
  factory FeedUrlPostgresReadModel.fromMap(Map<String, dynamic> map) {
    return FeedUrlPostgresReadModel(
      id: map[columnId] as String,
      userId: map[columnUserId] as String,
      url: map[columnUrl] as String,
      name: map[columnName] as String,
      createdAt: DateTime.parse(map[columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[columnUpdatedAt] as String),
    );
  }

  /// Convert read model to write model (strips out system-managed fields)
  FeedUrlPostgresWriteModel toWriteModel() {
    return FeedUrlPostgresWriteModel(
      id: id,
      userId: userId,
      url: url,
      name: name,
    );
  }
}
