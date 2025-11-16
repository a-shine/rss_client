// import '../../../domain/models/feed_url.dart';
// import '../../../utils/result.dart';
// import '../../services/feed_url_local_storage_service/feed_url_local_storage_service.dart';
// import 'feed_url_repository.dart';

// class FeedUrlRepositoryImpl implements FeedUrlRepository {
//   final FeedUrlLocalStorageService _storageService;

//   FeedUrlRepositoryImpl(this._storageService);

//   @override
//   Future<Result<List<FeedUrl>>> getFeedUrls() async {
//     try {
//       // The storage service already returns domain models (FeedUrl)
//       // The repository layer provides abstraction and could handle
//       // transformation if the service returned different models
//       return await _storageService.getFeedUrls();
//     } catch (e) {
//       return Result.error(Exception('Failed to get feed URLs: $e'));
//     }
//   }

//   @override
//   Future<Result<void>> addFeedUrl(FeedUrl feedUrl) async {
//     try {
//       return await _storageService.addFeedUrl(feedUrl);
//     } catch (e) {
//       return Result.error(Exception('Failed to add feed URL: $e'));
//     }
//   }

//   @override
//   Future<Result<void>> removeFeedUrl(String id) async {
//     try {
//       return await _storageService.removeFeedUrl(id);
//     } catch (e) {
//       return Result.error(Exception('Failed to remove feed URL: $e'));
//     }
//   }

//   @override
//   Future<Result<void>> updateFeedUrl(FeedUrl feedUrl) async {
//     try {
//       return await _storageService.updateFeedUrl(feedUrl);
//     } catch (e) {
//       return Result.error(Exception('Failed to update feed URL: $e'));
//     }
//   }

//   @override
//   Future<Result<bool>> urlExists(String url) async {
//     try {
//       return await _storageService.urlExists(url);
//     } catch (e) {
//       return Result.error(Exception('Failed to check if URL exists: $e'));
//     }
//   }
// }
