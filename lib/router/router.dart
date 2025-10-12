import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/article_repository/article_repository.dart';
import '../data/repositories/feed_url_repository/feed_url_repository.dart';
import '../data/repositories/rss_feed_repository/rss_feed_repository.dart';
import '../domain/models/article.dart';
import '../ui/home/view_models/home_feed_view_model.dart';
import '../ui/home/widgets/rss_feed_screen.dart';
import '../ui/manage_feeds/view_models/manage_feeds_view_model.dart';
import '../ui/manage_feeds/widgets/manage_feeds_screen.dart';
import '../ui/reader/widgets/article_reader_screen.dart';
import 'routes.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, _) => ChangeNotifierProvider(
          create: (_) => HomeFeedViewModel(
            rssFeedRepository: context.read<RssFeedRepository>(),
            articleRepository: context.read<ArticleRepository>(),
          ),
          child: const RssFeedScreen(),
        ),
        routes: [
          GoRoute(
            path: Routes.manageFeedsRelative,
            builder: (context, _) => ChangeNotifierProvider(
              create: (_) =>
                  ManageFeedsViewModel(context.read<FeedUrlRepository>()),
              child: const ManageFeedsScreen(),
            ),
          ),
          GoRoute(
            path: Routes.readerRelative,
            builder: (context, state) {
              final article = state.extra as Article;
              return ArticleReaderScreen(article: article);
            },
          ),
        ],
      ),
    ],
  );
}
