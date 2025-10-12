import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:readability/article.dart';
import 'package:readability/readability.dart' as readability;

import '../../../utils/result.dart';

class ArticleReaderService {
  /// Fetch and parse article content from a URL
  Future<Result<Article>> fetchArticle(String url) async {
    try {
      // Use the readability package which fetches and parses in one call
      // Note: This works on mobile/desktop but not on web
      if (kIsWeb) {
        throw Exception('Reader mode is not supported on web platform');
      }

      final article = await readability.parseAsync(url);
      return Result.ok(article);
    } catch (e) {
      return Result.error(Exception('Failed to fetch and parse article: $e'));
    }
  }
}
