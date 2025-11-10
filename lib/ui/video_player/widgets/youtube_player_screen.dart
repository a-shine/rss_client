import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const YoutubePlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Extract video ID from URL
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);

    if (videoId == null) {
      // Invalid YouTube URL
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
  }

  @override
  void deactivate() {
    // Pause video when leaving the screen
    _controller.pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);

    if (videoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invalid Video')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Unable to load video'),
              SizedBox(height: 8),
              Text(
                'This doesn\'t appear to be a valid YouTube URL',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Column(
            children: [
              // Video Player
              player,
              // Video Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      // Player controls info
                      YoutubeValueBuilder(
                        controller: _controller,
                        builder: (context, value) {
                          return Row(
                            children: [
                              Icon(
                                value.playerState == PlayerState.playing
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                value.playerState == PlayerState.playing
                                    ? 'Playing'
                                    : 'Paused',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
