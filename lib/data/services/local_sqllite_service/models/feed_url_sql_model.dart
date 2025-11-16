/// SQL model representing a feed URL row in the database
class FeedUrlSqlModel {
  static const String tableName = 'feed_urls';
  static const String columnId = 'id';
  static const String columnUrl = 'url';
  static const String columnName = 'name';

  final String id;
  final String url;
  final String name;

  FeedUrlSqlModel({required this.id, required this.url, required this.name});

  /// Convert from database map to SQL model
  factory FeedUrlSqlModel.fromMap(Map<String, dynamic> map) {
    return FeedUrlSqlModel(
      id: map[columnId] as String,
      url: map[columnUrl] as String,
      name: map[columnName] as String,
    );
  }

  /// Convert SQL model to database map
  Map<String, dynamic> toMap() {
    return {columnId: id, columnUrl: url, columnName: name};
  }

  /// SQL statement to create the table
  static String get createTableSql =>
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnUrl TEXT NOT NULL,
      $columnName TEXT NOT NULL
    )
  ''';
}
