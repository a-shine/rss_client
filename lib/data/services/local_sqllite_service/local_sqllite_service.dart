import 'package:sqflite/sqlite_api.dart';

import '../../../utils/result.dart';
import 'models/feed_url_sql_model.dart';

class LocalSqlliteService {
  LocalSqlliteService(Database? db) : _db = db;
  final Database? _db;

  /// Get all feed URLs from the database
  Future<Result<List<FeedUrlSqlModel>>> getAllFeedUrls() async {
    try {
      final db = _db;
      if (db == null) {
        return Result.error(Exception('Database is not initialized'));
      }

      final List<Map<String, dynamic>> maps = await db.query(
        FeedUrlSqlModel.tableName,
      );

      final feedUrls = maps.map((map) => FeedUrlSqlModel.fromMap(map)).toList();
      return Result.ok(feedUrls);
    } catch (e) {
      return Result.error(Exception('Failed to get feed URLs: $e'));
    }
  }

  /// Insert a new feed URL into the database
  Future<Result<void>> insertFeedUrl(FeedUrlSqlModel feedUrl) async {
    try {
      final db = _db;
      if (db == null) {
        return Result.error(Exception('Database is not initialized'));
      }

      await db.insert(
        FeedUrlSqlModel.tableName,
        feedUrl.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.ok(null);
    } catch (e) {
      print('Error inserting feed URL: $e');
      return Result.error(Exception('Failed to insert feed URL: $e'));
    }
  }

  /// Update an existing feed URL in the database
  Future<Result<void>> updateFeedUrl(FeedUrlSqlModel feedUrl) async {
    try {
      final db = _db;
      if (db == null) {
        return Result.error(Exception('Database is not initialized'));
      }

      await db.update(
        FeedUrlSqlModel.tableName,
        feedUrl.toMap(),
        where: '${FeedUrlSqlModel.columnId} = ?',
        whereArgs: [feedUrl.id],
      );
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to update feed URL: $e'));
    }
  }

  /// Delete a feed URL from the database by ID
  Future<Result<void>> deleteFeedUrl(String id) async {
    try {
      final db = _db;
      if (db == null) {
        return Result.error(Exception('Database is not initialized'));
      }

      await db.delete(
        FeedUrlSqlModel.tableName,
        where: '${FeedUrlSqlModel.columnId} = ?',
        whereArgs: [id],
      );
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to delete feed URL: $e'));
    }
  }

  /// Check if a feed URL exists by URL
  Future<Result<bool>> feedUrlExists(String url) async {
    try {
      final db = _db;
      if (db == null) {
        return Result.error(Exception('Database is not initialized'));
      }

      final List<Map<String, dynamic>> maps = await db.query(
        FeedUrlSqlModel.tableName,
        where: '${FeedUrlSqlModel.columnUrl} = ?',
        whereArgs: [url],
        limit: 1,
      );

      return Result.ok(maps.isNotEmpty);
    } catch (e) {
      return Result.error(Exception('Failed to check if feed URL exists: $e'));
    }
  }
}
