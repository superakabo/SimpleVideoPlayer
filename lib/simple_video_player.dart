library simple_video_player;

import 'package:flutter/material.dart';
import 'package:simple_video_player/simple_video_player_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SimpleVideoPlayer extends StatefulWidget {
  final SimpleVideoPlayerController videoPlayerController;
  final bool autoPlay;
  final bool loop;
  final bool mute;
  final bool autoDispose;

  SimpleVideoPlayer({
    required this.videoPlayerController,
    this.autoPlay = true,
    this.loop = true,
    this.mute = true,
    this.autoDispose = true,
  });

  @override
  _SimpleVideoPlayerState createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(vsync: this, duration: Duration(seconds: 5));

  @override
  void dispose() {
    if (!widget.autoDispose) return;
    widget.videoPlayerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.videoPlayerController.value.aspectRatio,
      child: VisibilityDetector(
        key: ValueKey(widget.videoPlayerController.hashCode),
        onVisibilityChanged: (VisibilityInfo info) async {
          if (info.visibleFraction >= 0.75) {
            await widget.videoPlayerController.initialize();
            widget.videoPlayerController.setLooping(widget.loop);
            if (widget.mute) widget.videoPlayerController.setVolume(0.0);
            if (widget.autoPlay) widget.videoPlayerController.play();
            _animationController.forward();
          } else {
            if (widget.videoPlayerController.value.isInitialized) {
              widget.videoPlayerController.pause();
            }
          }
        },
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.videoPlayerController,
          builder: (_, videoPlayerValue, __) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 330),
              child: (videoPlayerValue.isInitialized)
                  ? GestureDetector(
                      key: ValueKey(true),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final volume = (videoPlayerValue.volume == 0) ? 1.0 : 0.0;
                        widget.videoPlayerController.setVolume(volume);
                        _animationController.forward(from: 0.0);
                      },
                      child: Stack(
                        children: [
                          VideoPlayer(widget.videoPlayerController),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            width: 32,
                            height: 32,
                            child: ValueListenableBuilder<double>(
                              valueListenable: _animationController,
                              builder: (_, progress, __) {
                                return Visibility(
                                  visible: (progress < 1.0),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      (videoPlayerValue.volume == 0) ? Icons.volume_off : Icons.volume_up_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )

                  /// Mark: video thumbnail and download progress indicator
                  : ValueListenableBuilder<double?>(
                      key: ValueKey(false),
                      valueListenable: widget.videoPlayerController.downloadProgressNotifier,
                      builder: (_, progress, __) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            image: DecorationImage(
                              alignment: Alignment.topCenter,
                              image: CachedNetworkImageProvider(widget.videoPlayerController.thumbnail),
                            ),
                          ),
                          child: Visibility(
                            visible: (progress != null),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                backgroundColor: Colors.grey.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                                value: progress,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
