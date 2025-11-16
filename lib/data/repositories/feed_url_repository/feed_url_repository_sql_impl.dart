import '../../../domain/models/feed_url.dart';
import '../../../utils/result.dart';
import '../../services/local_sqllite_service/local_sqllite_service.dart';
import '../../services/local_sqllite_service/models/feed_url_sql_model.dart';
import 'feed_url_repository.dart';

class FeedUrlRepositorySqlImpl implements FeedUrlRepository {
  final LocalSqlliteService _sqlService;

  FeedUrlRepositorySqlImpl(this._sqlService);

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

  @override
  Future<Result<List<FeedUrl>>> getFeedUrls() async {
    try {
      final result = await _sqlService.getAllFeedUrls();
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
      final sqlModel = _domainToSqlModel(feedUrl);
      return await _sqlService.insertFeedUrl(sqlModel);
    } catch (e) {
      return Result.error(Exception('Failed to add feed URL: $e'));
    }
  }

  @override
  Future<Result<void>> removeFeedUrl(String id) async {
    try {
      return await _sqlService.deleteFeedUrl(id);
    } catch (e) {
      return Result.error(Exception('Failed to remove feed URL: $e'));
    }
  }

  @override
  Future<Result<void>> updateFeedUrl(FeedUrl feedUrl) async {
    try {
      final sqlModel = _domainToSqlModel(feedUrl);
      return await _sqlService.updateFeedUrl(sqlModel);
    } catch (e) {
      return Result.error(Exception('Failed to update feed URL: $e'));
    }
  }

  @override
  Future<Result<bool>> urlExists(String url) async {
    try {
      return await _sqlService.feedUrlExists(url);
    } catch (e) {
      return Result.error(Exception('Failed to check if URL exists: $e'));
    }
  }
}
