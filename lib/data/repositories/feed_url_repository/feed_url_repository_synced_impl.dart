import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';
import '../../services/local_sqllite_service/local_sqllite_service.dart';
import '../../services/local_sqllite_service/models/feed_url_sql_model.dart';
import '../../services/supabase_postgres_service/models/feed_url_postgres_model.dart';
import '../../services/supabase_postgres_service/supabase_postgres_service.dart';
import 'feed_url_repository.dart';

/// Repository implementation that syncs between local SQLite and Supabase Postgres
/// This is the primary implementation that should be used when both local and remote storage are available
class FeedUrlRepositorySyncedImpl implements FeedUrlRepository {
  final LocalSqlliteService _localService;
  final SupabasePostgresService _supabaseService;
  final SupabaseClient _supabaseClient;

  FeedUrlRepositorySyncedImpl({
    required LocalSqlliteService localService,
    required SupabasePostgresService supabaseService,
    required SupabaseClient supabaseClient,
  }) : _localService = localService,
       _supabaseService = supabaseService,
       _supabaseClient = supabaseClient;

  /// Get the current authenticated user's ID
  String? get _currentUserId => _supabaseClient.auth.currentUser?.id;

  /// Convert SQL model to domain model
  FeedUrl _sqlModelToDomain(FeedUrlSqlModel sqlModel) {
    return FeedUrl(id: sqlModel.id, url: sqlModel.url, name: sqlModel.name);
  }

  /// Convert domain model to SQL model
  FeedUrlSqlModel _domainToSqlModel(FeedUrl feedUrl) {
    return FeedUrlSqlModel(
      id: feedUrl.id,
      url: feedUrl.url,
      name: feedUrl.name,
    );
  }

  /// Convert domain model to Postgres write model
  FeedUrlPostgresWriteModel _domainToPostgresWriteModel(FeedUrl feedUrl) {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return FeedUrlPostgresWriteModel(
      id: feedUrl.id,
      userId: userId,
      url: feedUrl.url,
      name: feedUrl.name,
    );
  }

  @override
  Future<Result<List<FeedUrl>>> getFeedUrls() async {
    try {
      // Always read from local SQLite (fast)
      final result = await _localService.getAllFeedUrls();
      switch (result) {
        case Error():
          return Result.error(result.error);
        case Ok():
          final sqlModels = result.value;
          final domainModels = sqlModels.map(_sqlModelToDomain).toList();
          return Result.ok(domainModels);
      }
    } catch (e) {
      return Result.error(Exception('Failed to get feed URLs: $e'));
    }
  }

  @override
  Future<Result<void>> addFeedUrl(FeedUrl feedUrl) async {
    try {
      // Add to local first
      final sqlModel = _domainToSqlModel(feedUrl);
      final localResult = await _localService.insertFeedUrl(sqlModel);

      if (localResult is Error) {
        return Result.error(localResult.error);
      }

      // Try to sync to remote if user is authenticated (best effort)
      final userId = _currentUserId;
      if (userId != null) {
        final postgresModel = _domainToPostgresWriteModel(feedUrl);
        await _supabaseService.insertFeedUrl(postgresModel);
        // Ignore remote errors - local is source of truth
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to add feed URL: $e'));
    }
  }

  @override
  Future<Result<void>> removeFeedUrl(String id) async {
    try {
      // Remove from local first
      final localResult = await _localService.deleteFeedUrl(id);

      if (localResult is Error) {
        return Result.error(localResult.error);
      }

      // Try to sync to remote if user is authenticated (best effort)
      final userId = _currentUserId;
      if (userId != null) {
        await _supabaseService.deleteFeedUrl(id);
        // Ignore remote errors - local is source of truth
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to remove feed URL: $e'));
    }
  }

  @override
  Future<Result<void>> updateFeedUrl(FeedUrl feedUrl) async {
    try {
      // Update local first
      final sqlModel = _domainToSqlModel(feedUrl);
      final localResult = await _localService.updateFeedUrl(sqlModel);

      if (localResult is Error) {
        return Result.error(localResult.error);
      }

      // Try to sync to remote if user is authenticated (best effort)
      final userId = _currentUserId;
      if (userId != null) {
        final postgresModel = _domainToPostgresWriteModel(feedUrl);
        await _supabaseService.updateFeedUrl(postgresModel);
        // Ignore remote errors - local is source of truth
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to update feed URL: $e'));
    }
  }

  @override
  Future<Result<bool>> urlExists(String url) async {
    try {
      // Check local only (faster and local is source of truth)
      return await _localService.feedUrlExists(url);
    } catch (e) {
      return Result.error(Exception('Failed to check if URL exists: $e'));
    }
  }

  /// Sync all local feed URLs to Supabase
  /// This pushes the entire local state to the remote
  Future<Result<SyncResult>> syncToSupabase() async {
    try {
      // Check if user is authenticated
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(
          Exception('User not authenticated. Please sign in to sync.'),
        );
      }

      // Get all local feed URLs
      final localResult = await _localService.getAllFeedUrls();
      switch (localResult) {
        case Error():
          return Result.error(localResult.error);
        case Ok():
          final localFeeds = localResult.value;

          int uploadedCount = 0;
          final errors = <String>[];

          // Upload each local feed to Supabase using upsert
          for (final localFeed in localFeeds) {
            final postgresModel = FeedUrlPostgresWriteModel(
              id: localFeed.id,
              userId: userId,
              url: localFeed.url,
              name: localFeed.name,
            );

            final upsertResult = await _supabaseService.upsertFeedUrl(
              postgresModel,
            );
            switch (upsertResult) {
              case Ok():
                uploadedCount++;
              case Error():
                errors.add(
                  'Failed to sync ${localFeed.name}: ${upsertResult.error}',
                );
            }
          }

          if (errors.isNotEmpty) {
            return Result.error(
              Exception('Sync completed with errors:\n${errors.join('\n')}'),
            );
          }

          return Result.ok(
            SyncResult(
              uploaded: uploadedCount,
              downloaded: 0,
              message: 'Successfully synced $uploadedCount feed(s) to Supabase',
            ),
          );
      }
    } catch (e) {
      return Result.error(Exception('Failed to sync to Supabase: $e'));
    }
  }

  /// Sync from Supabase to local (download from remote to local)
  /// This pulls all remote data to local, creating or updating as needed
  Future<Result<SyncResult>> syncFromSupabase() async {
    try {
      // Check if user is authenticated
      final userId = _currentUserId;
      if (userId == null) {
        return Result.error(
          Exception('User not authenticated. Please sign in to sync.'),
        );
      }

      // Get all remote feed URLs
      final remoteResult = await _supabaseService.getAllFeedUrls();
      switch (remoteResult) {
        case Error():
          return Result.error(remoteResult.error);
        case Ok():
          final remoteFeeds = remoteResult.value;

          int downloadedCount = 0;
          final errors = <String>[];

          // Download each remote feed to local
          for (final remoteFeed in remoteFeeds) {
            final sqlModel = FeedUrlSqlModel(
              id: remoteFeed.id,
              url: remoteFeed.url,
              name: remoteFeed.name,
            );

            final insertResult = await _localService.insertFeedUrl(sqlModel);
            switch (insertResult) {
              case Ok():
                downloadedCount++;
              case Error():
                errors.add(
                  'Failed to download ${remoteFeed.name}: ${insertResult.error}',
                );
            }
          }

          if (errors.isNotEmpty) {
            return Result.error(
              Exception('Sync completed with errors:\n${errors.join('\n')}'),
            );
          }

          return Result.ok(
            SyncResult(
              uploaded: 0,
              downloaded: downloadedCount,
              message:
                  'Successfully synced $downloadedCount feed(s) from Supabase',
            ),
          );
      }
    } catch (e) {
      return Result.error(Exception('Failed to sync from Supabase: $e'));
    }
  }
}

/// Result of a sync operation
class SyncResult {
  final int uploaded;
  final int downloaded;
  final String message;

  SyncResult({
    required this.uploaded,
    required this.downloaded,
    required this.message,
  });
}
