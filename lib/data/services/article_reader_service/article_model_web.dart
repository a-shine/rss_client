/// Web-compatible Article model (mirrors the readability package Article class)
/// This is a stub implementation for web platform where dart:ffi is not available
class Article {
  final String? title;
  final String? author;
  final String? byline;
  final String? dir;
  final String? lang;
  final String? content;
  final String? textContent;
  final String? excerpt;
  final String? siteName;
  final int? length;
  final String? publishedTime;
  final String? image;
  final String? favicon;

  Article({
    this.title,
    this.author,
    this.byline,
    this.dir,
    this.lang,
    this.content,
    this.textContent,
    this.excerpt,
    this.siteName,
    this.length,
    this.publishedTime,
    this.image,
    this.favicon,
  });
}
