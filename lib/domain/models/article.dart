/// Represents a parsed article with readable content
class Article {
  final String title;
  final String? author;
  final DateTime? publishedDate;
  final String htmlContent; // HTML content
  final String url;
  final String? excerpt;
  final int? readingTimeMinutes;

  Article({
    required this.title,
    this.author,
    this.publishedDate,
    required this.htmlContent,
    required this.url,
    this.excerpt,
    this.readingTimeMinutes,
  });
}
