import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';

class AudioWaveBars extends StatelessWidget {
  final List<double> amplitudes;
  final double barWidth;
  final Color barColor;
  final Color backgroundColor;
  final Color barColorActive;
  final double height;
  final double? width;
  final double barBorderRadius;
  final double barSpacing;
  final EdgeInsets? margin;
  final double progress;
  final double minBarHeight;

  const AudioWaveBars({
    super.key,
    required this.amplitudes,
    this.barWidth = 2.0,
    this.barColor = UnikonColorTheme.audioWaveFormBGColor,
    this.barColorActive = UnikonColorTheme.messageSentIndicatorColor,
    this.backgroundColor = UnikonColorTheme.transparent,
    required this.height,
    this.width,
    this.barBorderRadius = 0.0,
    this.barSpacing = 1.0,
    this.margin,
    required this.progress,
    this.minBarHeight = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = width ?? constraints.maxWidth;

        return Container(
          width: containerWidth,
          height: height,
          color: backgroundColor,
          margin: margin,
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(containerWidth, height),
            painter: AudioWaveBarsPainter(
              amplitudes: amplitudes,
              barWidth: barWidth,
              barColor: barColor,
              barColorActive: barColorActive,
              barBorderRadius: barBorderRadius,
              barSpacing: barSpacing,
              progress: progress,
              minBarHeight: minBarHeight,
            ),
          ),
        );
      },
    );
  }
}

class AudioWaveBarsPainter extends CustomPainter {
  final List<double> amplitudes;
  final double barWidth;
  final Color barColor;
  final Color barColorActive;
  final double barBorderRadius;
  final double barSpacing;
  final double progress;
  final double minBarHeight;

  AudioWaveBarsPainter({
    required this.amplitudes,
    required this.barWidth,
    required this.barColor,
    required this.barColorActive,
    required this.barBorderRadius,
    required this.barSpacing,
    required this.progress,
    required this.minBarHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxAmplitude = amplitudes.isNotEmpty ? amplitudes.reduce(max) : 1;
    final centerY = size.height / 2;

    // Determine how many bars can fit within the width of the container
    final visibleBarsCount = (size.width / (barWidth + barSpacing)).floor();

    // Scale amplitudes to fit into the visibleBarsCount
    final scaledAmplitudes = List.generate(visibleBarsCount, (i) {
      final index = (i / visibleBarsCount * amplitudes.length).floor();
      return amplitudes[index];
    });

    // Draw bars
    for (int i = 0; i < visibleBarsCount; i++) {
      final amplitude = scaledAmplitudes[i];
      final height = (amplitude / maxAmplitude) * centerY;
      final barHeight = height < minBarHeight ? minBarHeight : height;

      final xOffset = i * (barWidth + barSpacing);

      final rect = Rect.fromLTWH(
        xOffset.toDouble(),
        centerY - barHeight,
        barWidth,
        barHeight * 2,
      );

      final rRect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(barBorderRadius),
      );

      // Determine if this bar is in the "played" portion based on progress
      final progressThreshold = progress * visibleBarsCount;
      final currentBarColor = i < progressThreshold ? barColorActive : barColor;

      final paint = Paint()
        ..color = currentBarColor
        ..style = PaintingStyle.fill;

      // Draw the bar
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveBarsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.amplitudes != amplitudes ||
        oldDelegate.barColor != barColor ||
        oldDelegate.barColorActive != barColorActive;
  }
}
