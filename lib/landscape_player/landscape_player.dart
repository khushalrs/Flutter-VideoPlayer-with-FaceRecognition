import 'package:aws_signin/utils/mock_data.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'landscape_player_controls.dart';

class LandscapePlayer extends StatefulWidget {
  List<String> data;
  LandscapePlayer({Key? key, required this.data}) : super(key: key);

  @override
  _LandscapePlayerState createState() => _LandscapePlayerState(data);
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  late FlickManager flickManager;
  List<String> data;
  _LandscapePlayerState(this.data);

  @override
  void initState() {
    super.initState();
    print("Video Url: $data[0]");
    flickManager = FlickManager(
        videoPlayerController:
            VideoPlayerController.network(data[0]));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlickVideoPlayer(
        flickManager: flickManager,
        preferredDeviceOrientation: [
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft
        ],
        systemUIOverlay: [],
        flickVideoWithControls: FlickVideoWithControls(
          controls: LandscapePlayerControls(data),
        ),
      ),
    );
  }
}
