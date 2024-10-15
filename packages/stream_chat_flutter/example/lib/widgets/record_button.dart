import 'dart:math';
import 'dart:developer' as dev;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

typedef RecordCallback = void Function(String);
typedef RecordingStartedCallback = void Function();

class RecordButton extends StatefulWidget {
  const RecordButton({
    super.key,
    required this.recordingFinishedCallback,
    required this.recordingStartedCallback,
    required this.controller,
  });

  final RecordCallback recordingFinishedCallback;
  final RecordingStartedCallback recordingStartedCallback;
  final RecorderController controller;

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;

  Future<void> _start() async {
    try {
      if (await widget.controller.checkPermission()) {
        final tempDir = await getTemporaryDirectory();
        await widget.controller.record(
            path: "${tempDir.path}/${Random.secure().nextInt(999999)}.wav");
        if (widget.controller.isRecording) {
          widget.recordingStartedCallback();
        }
        setState(() {
          _isRecording = widget.controller.isRecording;
        });
      }
    } catch (e) {
      dev.log(e.toString());
    }
  }

  Future<void> _stop() async {
    final path = await widget.controller.stop();

    widget.recordingFinishedCallback(path!);

    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color? color;
    if (_isRecording) {
      icon = Icons.stop;
      color = Colors.red.withOpacity(0.3);
    } else {
      color = StreamChatTheme.of(context).primaryIconTheme.color;
      icon = Icons.mic;
    }

    return IconButton(
      onPressed: () => _isRecording ? _stop() : _start(),
      icon: Icon(
        icon,
        color: color,
      ),
    );
  }
}
