/*
 * Created on Sat Apr 03 2021
 *
 * Copyright (c) 2021 Akabo Samuel
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayerController extends VideoPlayerController {
  final downloadProgressNotifier = ValueNotifier<int>(0);
  final bool _cache;
  StreamSubscription<FileResponse>? _streamSubscription;

  String _dataSource = '';
  @override
  String get dataSource => _dataSource;

  DataSourceType _dataSourceType;
  @override
  DataSourceType get dataSourceType => _dataSourceType;

  SimpleVideoPlayerController._network(
    this._dataSource,
    this._cache, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const {},
  })  : this._dataSourceType = DataSourceType.network,
        super.network(
          _dataSource,
          formatHint: formatHint,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
          httpHeaders: httpHeaders,
        );

  SimpleVideoPlayerController._asset(
    this._dataSource, {
    String? package,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  })  : this._cache = false,
        this._dataSourceType = DataSourceType.asset,
        super.asset(
          _dataSource,
          package: package,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
        );

  SimpleVideoPlayerController._file(
    File file, {
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  })  : this._cache = false,
        this._dataSourceType = DataSourceType.file,
        super.file(
          file,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
        );

  factory SimpleVideoPlayerController.fromNetwork(
    String dataSource, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    bool cache = true,
  }) {
    return SimpleVideoPlayerController._network(
      dataSource,
      cache,
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  factory SimpleVideoPlayerController.fromAsset(
    String dataSource, {
    String? package,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  }) {
    return SimpleVideoPlayerController._asset(
      dataSource,
      package: package,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  factory SimpleVideoPlayerController.fromFile(File file,
      {Future<ClosedCaptionFile>? closedCaptionFile, VideoPlayerOptions? videoPlayerOptions}) {
    return SimpleVideoPlayerController._file(
      file,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  /// Mark: stream or download video if it is not cached.
  Future<void> _startCaching() async {
    if (!dataSource.startsWith('http')) return;

    final _fileDownloadCompleter = Completer<void>();

    _streamSubscription = DefaultCacheManager().getFileStream(dataSource, withProgress: true).listen((response) {
      if (response is DownloadProgress) {
        if (response.progress == null) return;
        downloadProgressNotifier.value = (response.progress! * 100).toInt();
      }

      if (response is FileInfo) {
        _dataSource = 'file://${response.file.path}';
        _dataSourceType = (response.source == FileSource.Cache) ? DataSourceType.file : DataSourceType.network;
        _fileDownloadCompleter.complete();
      }
    });

    return await _fileDownloadCompleter.future;
  }

  @override
  Future<void> initialize() async {
    if (_cache) await _startCaching();
    return super.initialize();
  }

  @override
  Future<void> dispose() {
    _streamSubscription?.cancel();
    downloadProgressNotifier.dispose();
    return super.dispose();
  }
}
