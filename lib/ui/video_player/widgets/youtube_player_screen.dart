import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();

    // Extract video ID from URL
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId == null) {
      // Invalid YouTube URL
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    // Pause video when leaving the screen
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

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

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // Reset device orientation when exiting fullscreen
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          // Optional: Handle when video ends
        },
      ),
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
                      if (_controller.value.isPlaying)
                        const Row(
                          children: [
                            Icon(Icons.play_arrow, size: 16),
                            SizedBox(width: 4),
                            Text('Playing'),
                          ],
                        )
                      else
                        const Row(
                          children: [
                            Icon(Icons.pause, size: 16),
                            SizedBox(width: 4),
                            Text('Paused'),
                          ],
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
