import '../../../utils/result.dart';
// Conditional imports: use different implementations based on platform
// The Article class is exported from the platform-specific implementations
import 'article_reader_service_stub.dart'
    if (dart.library.io) 'article_reader_service_io.dart'
    if (dart.library.html) 'article_reader_service_web.dart';

class ArticleReaderService {
  final ArticleReaderServiceImpl _impl = ArticleReaderServiceImpl();

  /// Fetch and parse article content from a URL
  /// On web platform, this will return an error since readability is not supported
  Future<Result<Article>> fetchArticle(String url) async {
    return _impl.fetchArticle(url);
  }
}
