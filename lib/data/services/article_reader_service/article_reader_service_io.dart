import 'package:readability/article.dart';
import 'package:readability/readability.dart' as readability;

import '../../../utils/result.dart';

// Export the readability Article class
export 'package:readability/article.dart';

/// Native implementation (iOS, Android, Desktop)
class ArticleReaderServiceImpl {
  Future<Result<Article>> fetchArticle(String url) async {
    try {
      final article = await readability.parseAsync(url);
      return Result.ok(article);
    } catch (e) {
      return Result.error(Exception('Failed to fetch and parse article: $e'));
    }
  }
}
