import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/message_input/voice_notes/audio_loading_message.dart';
import 'package:stream_chat_flutter/src/message_input/voice_notes/audio_wave_bars.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A widget that displays an audio message with a play/pause button
/// and a waveform visualizer.
class AudioPlayerMessage extends StatefulWidget {
  /// Creates an audio player message widget
  const AudioPlayerMessage({
    super.key,
    required this.source,
    required this.id,
    this.localFilePath,
    this.fileWaveFormData,
    required this.isMyMessage,
    required this.message,
  });

  /// The audio source to play
  final AudioSource source;

  /// The local file path of the audio file
  final String? localFilePath;

  /// The message id
  final String id;

  /// The waveform data of the audio file
  final List<double>? fileWaveFormData;

  /// If the message is sent by the current user
  final bool isMyMessage;

  /// The message object
  final Message message;

  @override
  _AudioPlayerMessageState createState() => _AudioPlayerMessageState();
}

class _AudioPlayerMessageState extends State<AudioPlayerMessage> {
  final _audioPlayer = AudioPlayer();

  late Future<Duration?> futureDuration;

  double _progress = 0;
  Duration? _totalDuration;
  String audioDuration = '0:00';

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

  /// Get the initials of a user
  String _getInitials(String name) {
    return name.split(' ').map((word) => word[0]).join();
  }

  @override
  Widget build(BuildContext context) {
    final audioWidget = <Widget>[
      _buildUserProfilePic(),
      if (widget.fileWaveFormData != null)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
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

  Padding _buildUserProfilePic() {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (widget.message.user?.image != null)
            Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  imageUrl: widget.message.user!.image!,
                ),
              ),
            )
          else
            Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isMyMessage
                        ? UnikonColorTheme.audioUserProfileColor1
                        : UnikonColorTheme.replyQuotedMessageBGColor,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(widget.message.user!.name).toUpperCase(),
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
