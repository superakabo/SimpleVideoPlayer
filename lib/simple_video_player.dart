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
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final Function(VisibilityInfo)? onVisibilityChanged;

  SimpleVideoPlayer({
    required this.videoPlayerController,
    this.autoPlay = true,
    this.loop = true,
    this.mute = true,
    this.autoDispose = true,
    this.onTap,
    this.onDoubleTap,
    this.onVisibilityChanged,
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
    return VisibilityDetector(
      key: ValueKey(widget.videoPlayerController.dataSource),
      onVisibilityChanged: (VisibilityInfo info) {
        if (widget.onVisibilityChanged != null) {
          widget.onVisibilityChanged!(info);
        }

        final playerValue = widget.videoPlayerController.value;

        if (info.visibleFraction >= 0.75) {
          if (playerValue.isInitialized) {
            if (widget.autoPlay) widget.videoPlayerController.play();
          } else
            widget.videoPlayerController.initialize().then((_) {
              if (widget.mute) widget.videoPlayerController.setVolume(0.0);
              if (widget.autoPlay) widget.videoPlayerController.play();
              widget.videoPlayerController.setLooping(widget.loop);
              _animationController.forward();
            });
        } else if (info.visibleFraction <= 0.15) {
          if (playerValue.isInitialized && playerValue.isPlaying) {
            widget.videoPlayerController.pause();
          }
        }
      },
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.videoPlayerController,
        builder: (_, videoPlayerValue, __) {
          return AspectRatio(
            aspectRatio: videoPlayerValue.aspectRatio,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: (videoPlayerValue.isInitialized)
                  ? GestureDetector(
                      key: ValueKey(true),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (widget.onTap == null) {
                          final volume = (videoPlayerValue.volume == 0) ? 1.0 : 0.0;
                          widget.videoPlayerController.setVolume(volume);
                          _animationController.forward(from: 0.0);
                        } else {
                          widget.onTap!();
                        }
                      },
                      onDoubleTap: widget.onDoubleTap,
                      child: Stack(
                        children: [
                          VideoPlayer(widget.videoPlayerController),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            width: 26,
                            height: 26,
                            child: ValueListenableBuilder<double>(
                              valueListenable: _animationController,
                              builder: (_, progress, __) {
                                return Visibility(
                                  visible: (progress < 1.0),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      (videoPlayerValue.volume == 0) ? Icons.volume_off : Icons.volume_up_rounded,
                                      size: 14,
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
                            image: (widget.videoPlayerController.thumbnail.isEmpty)
                                ? null
                                : DecorationImage(
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
            ),
          );
        },
      ),
    );
  }
}
