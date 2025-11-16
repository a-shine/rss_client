import 'package:flutter/foundation.dart';
import 'package:rss_client/utils/command.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/feed_url_repository/feed_url_repository.dart';
import '../../../data/repositories/feed_url_repository/feed_url_repository_synced_impl.dart';
import '../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';

class AddFeedForm {
  const AddFeedForm({this.url = '', this.name = ''});

  final String url;
  final String name;
}

class ManageFeedsViewModel extends ChangeNotifier {
  ManageFeedsViewModel(this._feedUrlRepository) {
    load = Command0<void>(_load)..execute();
    addFeed = Command1<void, AddFeedForm>(_addFeedUrl);
    removeFeed = Command1<void, String>(_removeFeedUrl);
    syncFeeds = Command0<String>(_syncFeeds);
  }

  // Dependencies
  final FeedUrlRepository _feedUrlRepository;

  // Commands
  late Command0<void> load;
  late Command1<void, AddFeedForm> addFeed;
  late Command1<void, String> removeFeed;
  late Command0<String> syncFeeds;

  // State
  final List<FeedUrl> _feedUrls = [];
  List<FeedUrl> get feedUrls => _feedUrls;

  /// Load all feed URLs from storage
  Future<Result<void>> _load() async {
    final result = await _feedUrlRepository.getFeedUrls();
    switch (result) {
      case Ok():
        _feedUrls
          ..clear()
          ..addAll(result.value);
        return Result.ok(null);
      case Error():
        return Result.error(result.error);
    }
  }

  /// Add a new feed URL
  Future<Result<void>> _addFeedUrl(AddFeedForm form) async {
    // Check if URL already exists
    final existsResult = await _feedUrlRepository.urlExists(form.url);

    switch (existsResult) {
      case Error():
        return Result.error(
          Exception('Failed to check if URL exists: ${existsResult.error}'),
        );
      case Ok():
        if (existsResult.value) {
          return Result.error(Exception('This feed URL already exists'));
        }
    }

    final feedUrl = FeedUrl(
      id: const Uuid().v4(),
      url: form.url,
      name: form.name,
    );

    final result = await _feedUrlRepository.addFeedUrl(feedUrl);

    switch (result) {
      case Error():
        return Result.error(result.error);
      case Ok():
        break; // Continue to reload the list
    }
    load.execute(); // Refresh the list
    return Result.ok(null);
  }

  /// Remove a feed URL
  Future<Result<void>> _removeFeedUrl(String id) async {
    try {
      final result = await _feedUrlRepository.removeFeedUrl(id);

      switch (result) {
        case Error():
          return Result.error(
            Exception('Failed to remove feed URL: ${result.error}'),
          );
        case Ok():
          break; // Continue to reload the list
      }
      load.execute(); // Refresh the list
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to remove feed URL: $e'));
    }
  }

  /// Sync feeds from local SQLite to Supabase
  Future<Result<String>> _syncFeeds() async {
    try {
      // Check if the repository supports syncing
      if (_feedUrlRepository is! FeedUrlRepositorySyncedImpl) {
        return Result.error(
          Exception('Sync is not supported with current configuration'),
        );
      }

      // ignore: unnecessary_cast
      final syncedRepo = _feedUrlRepository as FeedUrlRepositorySyncedImpl;
      final result = await syncedRepo.syncToSupabase();

      switch (result) {
        case Error():
          return Result.error(result.error);
        case Ok():
          load.execute(); // Refresh the list after sync
          return Result.ok(result.value.message);
      }
    } catch (e) {
      return Result.error(Exception('Failed to sync feeds: $e'));
    }
  }
}
