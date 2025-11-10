import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/article_repository/article_repository.dart';
import '../data/repositories/feed_url_repository/feed_url_repository.dart';
import '../data/repositories/rss_feed_repository/rss_feed_repository.dart';
import '../data/repositories/user_repository/user_repository.dart';
import '../domain/models/article.dart';
import '../ui/app/app.dart';
import '../ui/home/view_models/home_feed_view_model.dart';
import '../ui/home/widgets/rss_feed_screen.dart';
import '../ui/manage_feeds/view_models/manage_feeds_view_model.dart';
import '../ui/manage_feeds/widgets/manage_feeds_screen.dart';
import '../ui/reader/widgets/article_reader_screen.dart';
import '../ui/sign_in/view_models/sign_in_view_model.dart';
import '../ui/sign_in/widgets/sign_in_screen.dart';
import '../ui/video_player/widgets/youtube_player_screen.dart';
import 'routes.dart';

GoRouter createRouter(AuthStateNotifier authStateNotifier) {
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) async {
      final user = await authStateNotifier.currentUser;
      final isSignInRoute = state.matchedLocation == Routes.signIn;

      // If user is not authenticated and not on sign-in page, redirect to sign-in
      if (user == null && !isSignInRoute) {
        return Routes.signIn;
      }

      // If user is authenticated and on sign-in page, redirect to home
      if (user != null && isSignInRoute) {
        return Routes.home;
      }

      // No redirect needed
      return null;
    },
    refreshListenable: authStateNotifier,
    routes: [
      GoRoute(
        path: Routes.signIn,
        builder: (context, _) => ChangeNotifierProvider(
          create: (_) => SignInViewModel(context.read<UserRepository>()),
          child: const SignInScreen(),
        ),
      ),
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
          GoRoute(
            path: Routes.videoPlayerRelative,
            builder: (context, state) {
              final data = state.extra as Map<String, String>;
              return YoutubePlayerScreen(
                videoUrl: data['url']!,
                title: data['title']!,
              );
            },
          ),
        ],
      ),
    ],
  );
}
