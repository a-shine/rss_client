import '../../../domain/models/article.dart';
import '../../../utils/result.dart';
import '../../services/article_reader_service/article_reader_service.dart';

class ArticleRepository {
  ArticleRepository({ArticleReaderService? articleParserService})
    : _article_parser_service = articleParserService ?? ArticleReaderService();

  final ArticleReaderService _article_parser_service;

  Future<Result<Article>> fetchAndParseArticle(String url) async {
    try {
      final serviceArticleResult = await _article_parser_service.fetchArticle(
        url,
      );

      switch (serviceArticleResult) {
        case Error():
          return Result.error(serviceArticleResult.error);
        case Ok():
          final serviceArticle = serviceArticleResult.value;
          // Convert the external Article to your domain Article model
          return Result.ok(
            Article(
              title: serviceArticle.title ?? 'No Title',
              author: serviceArticle.author ?? 'Unknown',
              publishedDate: serviceArticle.publishedTime != null
                  ? DateTime.tryParse(serviceArticle.publishedTime!)
                  : null,
              htmlContent: serviceArticle.content ?? '',
              url: url,
            ),
          );
      }
    } catch (e) {
      return Result.error(Exception('Failed to fetch and parse article: $e'));
    }
  }
}
