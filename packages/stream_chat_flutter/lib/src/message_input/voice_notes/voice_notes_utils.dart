import 'dart:math' as math;

/// Utility functions for generating and manipulating waveform data
class WaveformUtils {
  const WaveformUtils._();

  /// Generates a dummy waveform pattern that mimics natural audio waves
  ///
  /// Parameters:
  /// - [sampleCount] determines how many samples to generate
  /// - [minAmplitude] is the minimum wave height (0.0 to 1.0)
  /// - [maxAmplitude] is the maximum wave height (0.0 to 1.0)
  /// - [smoothness] controls how smooth the transitions are (1 to 10, higher = smoother)
  ///
  /// Returns a List<double> containing the generated waveform data
  static List<double> generateDummyWaveform({
    int sampleCount = 100,
    double minAmplitude = 0.2,
    double maxAmplitude = 0.8,
    int smoothness = 4,
  }) {
    assert(minAmplitude >= 0.0 && minAmplitude <= 1.0);
    assert(maxAmplitude >= 0.0 && maxAmplitude <= 1.0);
    assert(maxAmplitude > minAmplitude);
    assert(smoothness >= 1 && smoothness <= 10);

    final waveform = <double>[];
    final random = math.Random(42); // Fixed seed for consistent results

    // Generate control points for smooth interpolation
    final controlPoints = List.generate(
      (sampleCount / smoothness).ceil() + 2,
      (_) => minAmplitude + random.nextDouble() * (maxAmplitude - minAmplitude),
    );

    // Generate smooth waveform using control points
    for (var i = 0; i < sampleCount; i++) {
      final progress = i / sampleCount * (controlPoints.length - 3);
      final index = progress.floor();
      final t = progress - index;

      // Cubic interpolation between control points
      final p0 = controlPoints[index];
      final p1 = controlPoints[index + 1];
      final p2 = controlPoints[index + 2];
      final p3 = controlPoints[index + 3];

      // Catmull-Rom spline interpolation
      final value = 0.5 *
          ((2 * p1) +
              (-p0 + p2) * t +
              (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t +
              (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t);

      // Ensure value stays within bounds
      waveform.add(value.clamp(minAmplitude, maxAmplitude));
    }

    return waveform;
  }
}
