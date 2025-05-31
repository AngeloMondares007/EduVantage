import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;
  final String title;

  const AudioPlayerScreen({
    required this.audioUrl,
    required this.title,
  });

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
        });
      } else if (state == PlayerState.paused) {
        setState(() {
          _isPlaying = false;
        });
      } else if (state == PlayerState.stopped) {
        setState(() {
          _isPlaying = false;
          _position = _duration;
        });
      }
    });
    //
    // _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Future<void> _initAudioPlayer() async {
  //   await _audioPlayer.setSourceUrl(widget.audioUrl);
  //   _audioPlayer.play(widget.audioUrl);
  // }

  void _playPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    _audioPlayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? CircularProgressIndicator()
                : Column(
              children: [
                Text(
                  'Playing Audio:',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: () {
                        _seekToSecond(0);
                      },
                    ),
                    IconButton(
                      icon: _isPlaying
                          ? Icon(Icons.pause)
                          : Icon(Icons.play_arrow),
                      onPressed: _playPause,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        _seekToSecond(_duration.inSeconds);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Slider(
                  value: _position.inSeconds.toDouble(),
                  min: 0.0,
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (double value) {
                    _seekToSecond(value.toInt());
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
