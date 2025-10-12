import '../../../domain/models/feed_url.dart';
import '../../services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
import 'feed_url_repository.dart';

class FeedUrlRepositoryImpl implements FeedUrlRepository {
  final FeedUrlLocalStorageService _storageService;

  FeedUrlRepositoryImpl(this._storageService);

  @override
  Future<List<FeedUrl>> getFeedUrls() async {
    // In this case, the storage service already returns domain models (FeedUrl)
    // But the repository layer provides abstraction and could handle
    // transformation if the service returned different models
    return await _storageService.getFeedUrls();
  }

  @override
  Future<void> addFeedUrl(FeedUrl feedUrl) async {
    await _storageService.addFeedUrl(feedUrl);
  }

  @override
  Future<void> removeFeedUrl(String id) async {
    await _storageService.removeFeedUrl(id);
  }

  @override
  Future<void> updateFeedUrl(FeedUrl feedUrl) async {
    await _storageService.updateFeedUrl(feedUrl);
  }

  @override
  Future<bool> urlExists(String url) async {
    return await _storageService.urlExists(url);
  }
}
