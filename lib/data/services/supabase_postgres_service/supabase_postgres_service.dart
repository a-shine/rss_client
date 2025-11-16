import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../utils/result.dart';
import 'models/feed_url_postgres_model.dart';

class SupabasePostgresService {
  SupabasePostgresService(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  /// Get the current authenticated user's ID
  String? get _currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Get all feed URLs for the current user from Supabase
  /// RLS policies automatically filter by user_id, but we're explicit here
  Future<Result<List<FeedUrlPostgresReadModel>>> getAllFeedUrls() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(Exception('User not authenticated'));
      }

      final response = await _supabaseClient
          .from(FeedUrlPostgresReadModel.tableName)
          .select()
          .eq(FeedUrlPostgresReadModel.columnUserId, userId);

      final feedUrls = (response as List)
          .map((map) => FeedUrlPostgresReadModel.fromMap(map))
          .toList();

      return Result.ok(feedUrls);
    } catch (e) {
      return Result.error(
        Exception('Failed to get feed URLs from Supabase: $e'),
      );
    }
  }

  /// Insert a new feed URL into Supabase for the current user
  Future<Result<void>> insertFeedUrl(FeedUrlPostgresWriteModel feedUrl) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(Exception('User not authenticated'));
      }

      // Ensure the feedUrl has the correct user_id
      if (feedUrl.userId != userId) {
        return Result.error(
          Exception('Cannot insert feed URL for another user'),
        );
      }

      await _supabaseClient
          .from(FeedUrlPostgresWriteModel.tableName)
          .insert(feedUrl.toMap());

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception('Failed to insert feed URL to Supabase: $e'),
      );
    }
  }

  /// Update an existing feed URL in Supabase (only if owned by current user)
  Future<Result<void>> updateFeedUrl(FeedUrlPostgresWriteModel feedUrl) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(Exception('User not authenticated'));
      }

      // Ensure the feedUrl has the correct user_id
      if (feedUrl.userId != userId) {
        return Result.error(
          Exception('Cannot update feed URL for another user'),
        );
      }

      await _supabaseClient
          .from(FeedUrlPostgresWriteModel.tableName)
          .update(feedUrl.toMap())
          .eq(FeedUrlPostgresWriteModel.columnId, feedUrl.id)
          .eq(FeedUrlPostgresWriteModel.columnUserId, userId);

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception('Failed to update feed URL in Supabase: $e'),
      );
    }
  }

  /// Delete a feed URL from Supabase by ID (only if owned by current user)
  Future<Result<void>> deleteFeedUrl(String id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(Exception('User not authenticated'));
      }

      await _supabaseClient
          .from(FeedUrlPostgresWriteModel.tableName)
          .delete()
          .eq(FeedUrlPostgresWriteModel.columnId, id)
          .eq(FeedUrlPostgresWriteModel.columnUserId, userId);

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception('Failed to delete feed URL from Supabase: $e'),
      );
    }
  }

  /// Check if a feed URL exists by URL in Supabase for the current user
  Future<Result<bool>> feedUrlExists(String url) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(Exception('User not authenticated'));
      }

      final response = await _supabaseClient
          .from(FeedUrlPostgresReadModel.tableName)
          .select()
          .eq(FeedUrlPostgresReadModel.columnUrl, url)
          .eq(FeedUrlPostgresReadModel.columnUserId, userId)
          .maybeSingle();

      return Result.ok(response != null);
    } catch (e) {
      return Result.error(
        Exception('Failed to check if feed URL exists in Supabase: $e'),
      );
    }
  }

  /// Upsert (insert or update) a feed URL in Supabase for the current user
  Future<Result<void>> upsertFeedUrl(FeedUrlPostgresWriteModel feedUrl) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(Exception('User not authenticated'));
      }

      // Ensure the feedUrl has the correct user_id
      if (feedUrl.userId != userId) {
        return Result.error(
          Exception('Cannot upsert feed URL for another user'),
        );
      }

      await _supabaseClient
          .from(FeedUrlPostgresWriteModel.tableName)
          .upsert(feedUrl.toMap());

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception('Failed to upsert feed URL in Supabase: $e'),
      );
    }
  }
}
