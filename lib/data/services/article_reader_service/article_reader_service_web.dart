import '../../../utils/result.dart';
import 'article_model_web.dart';

// Export the web-compatible Article model
export 'article_model_web.dart';

/// Web implementation (doesn't use readability package)
class ArticleReaderServiceImpl {
  Future<Result<Article>> fetchArticle(String url) async {
    // Return an error since readability is not supported on web
    return Result.error(
      Exception(
        'Reader mode is not supported on web platform. The readability package requires dart:ffi which is not available on web.',
      ),
    );
  }
}
