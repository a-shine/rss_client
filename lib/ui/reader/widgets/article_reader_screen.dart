import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/models/article.dart';

class ArticleReaderScreen extends StatelessWidget {
  final Article article;

  const ArticleReaderScreen({super.key, required this.article});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Silently fail if URL can't be opened
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in browser',
            onPressed: () => _launchUrl(article.url),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Metadata row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (article.author != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        article.author!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
                if (article.readingTimeMinutes != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${article.readingTimeMinutes} min read',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
                if (article.publishedDate != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.publishedDate != null
                            ? DateFormat.yMMMd().add_jm().format(
                                article.publishedDate!.toLocal(),
                              )
                            : '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const Divider(height: 32),

            // Article content
            Html(
              data: article.htmlContent,
              style: {
                'body': Style(
                  fontSize: FontSize(18),
                  lineHeight: const LineHeight(1.6),
                ),
                'p': Style(margin: Margins.only(bottom: 16)),
                'h1': Style(
                  fontSize: FontSize(28),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(top: 24, bottom: 16),
                ),
                'h2': Style(
                  fontSize: FontSize(24),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(top: 20, bottom: 12),
                ),
                'h3': Style(
                  fontSize: FontSize(20),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(top: 16, bottom: 8),
                ),
                'img': Style(
                  width: Width(100, Unit.percent),
                  margin: Margins.symmetric(vertical: 16),
                ),
                'blockquote': Style(
                  border: Border(
                    left: BorderSide(color: Colors.grey[400]!, width: 4),
                  ),
                  margin: Margins.symmetric(vertical: 16),
                  padding: HtmlPaddings.only(left: 16),
                  fontStyle: FontStyle.italic,
                ),
                'code': Style(
                  backgroundColor: Colors.grey[200],
                  padding: HtmlPaddings.all(4),
                  fontFamily: 'monospace',
                ),
                'pre': Style(
                  backgroundColor: Colors.grey[200],
                  padding: HtmlPaddings.all(12),
                  margin: Margins.symmetric(vertical: 16),
                ),
              },
              onLinkTap: (url, attributes, element) {
                if (url != null) {
                  _launchUrl(url);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
