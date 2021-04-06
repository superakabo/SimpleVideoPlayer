import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_video_player/simple_video_player.dart';
import 'package:simple_video_player/simple_video_player_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey.shade100,
        primaryColorBrightness: Brightness.light,
        brightness: Brightness.light,
      ),
      home: Example(),
    );
  }
}

class Example extends StatelessWidget {
  static const videoUrl = 'https://storage.googleapis.com/whatsad-84167.appspot.com/ads/p835.mp4';
  static const thumbnail = 'https://storage.googleapis.com/whatsad-84167.appspot.com/ads/p835.jpg';
  late final videoPlayerController = SimpleVideoPlayerController.fromNetwork(videoUrl, thumbnail: thumbnail);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SimpleVideoPlayer(
        videoPlayerController: videoPlayerController,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Play / Pause',
        child: Icon(Icons.add),
        onPressed: () async {
          (videoPlayerController.value.isPlaying) ? videoPlayerController.pause() : videoPlayerController.play();
        },
      ),
    );
  }
}
