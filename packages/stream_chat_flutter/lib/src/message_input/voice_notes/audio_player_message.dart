import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/message_input/voice_notes/audio_loading_message.dart';
import 'package:stream_chat_flutter/src/message_input/voice_notes/audio_wave_bars.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AudioPlayerMessage extends StatefulWidget {
  const AudioPlayerMessage({
    super.key,
    required this.source,
    required this.id,
    this.localFilePath,
    this.fileWaveFormData,
    required this.isMyMessage,
    required this.message,
  });

  final AudioSource source;
  final String? localFilePath;
  final String id;
  final List<double>? fileWaveFormData;
  final bool isMyMessage;
  final Message message;

  @override
  AudioPlayerMessageState createState() => AudioPlayerMessageState();
}

class AudioPlayerMessageState extends State<AudioPlayerMessage> {
  final _audioPlayer = AudioPlayer();

  late Future<Duration?> futureDuration;
  double _progress = 0.0;
  Duration? _totalDuration;
  String audioDuration = "0:00";
  @override
  void initState() {
    super.initState();

    futureDuration = _audioPlayer.setAudioSource(widget.source);

    // Listen to the duration stream to get the total duration
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
          _totalDuration = duration;
          audioDuration = _totalDuration?.toString().split('.').first ?? '0:00';
          audioDuration = audioDuration.split(':').sublist(1).join(':');
        });
      }
    });

    // Update progress based on current position and total duration
    _audioPlayer.positionStream.listen((position) async {
      final totalDuration = _totalDuration;
      if (totalDuration != null && totalDuration.inMilliseconds > 0) {
        setState(() {
          final progress = position.inMilliseconds.toDouble() /
              totalDuration.inMilliseconds.toDouble();
          _progress = progress.clamp(0.0, 1.0);
        });
        if (_progress == 1.0) {
          await reset();
        }
      } else {
        // Duration is not yet available
        setState(() {
          _progress = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> audioWidget = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            if (widget.message.user?.image != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    height: 40,
                    width: 40,
                    imageUrl: widget.message.user!.image!,
                  ),
                ),
              )
            else
              Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isMyMessage
                          ? UnikonColorTheme.whiteHintTextColor
                          : UnikonColorTheme.primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        widget.message.user!.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
            const Icon(
              Icons.mic,
              size: 20,
              color: UnikonColorTheme.messageSentIndicatorColor,
            ),
          ],
        ),
      ),
      if (widget.fileWaveFormData != null)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _controlButtons(),
                  AudioWaveBars(
                    amplitudes: widget.fileWaveFormData!,
                    height: 35,
                    barSpacing: 2,
                    width: MediaQuery.of(context).size.width * 0.35,
                    progress: _progress,
                    barBorderRadius: 10,
                  ),
                ],
              ),
              Text(
                audioDuration,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
    ];
    return FutureBuilder<Duration?>(
      future: futureDuration,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.isMyMessage
                  ? audioWidget
                  : audioWidget.reversed.toList(),
            ),
          );
        }
        return const AudioLoadingMessage();
      },
    );
  }

  Widget _controlButtons() {
    return StreamBuilder<bool>(
      stream: _audioPlayer.playingStream,
      builder: (context, snapshot) {
        const color = Colors.white;
        final icon = snapshot.data == true ? Icons.pause : Icons.play_arrow;

        return GestureDetector(
          onTap: () {
            if (snapshot.data == true) {
              pause();
            } else {
              play();
            }
          },
          child: Icon(icon, color: color, size: 30),
        );
      },
    );
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
    setState(() {
      _progress = 0.0;
    });
  }
}
