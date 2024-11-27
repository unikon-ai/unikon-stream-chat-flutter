import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/attachment/thumbnail/image_attachment_thumbnail.dart';
import 'package:stream_chat_flutter/src/attachment/thumbnail/thumbnail_error.dart';
import 'package:stream_chat_flutter/src/attachment/thumbnail/video_attachment_thumbnail.dart';
import 'package:stream_chat_flutter/src/utils/helpers.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

/// {@template streamFileAttachmentThumbnail}
/// Widget for building file attachment thumbnail.
///
/// This widget first tries to build an image thumbnail for the file attachment.
/// If the image thumbnail fails to load, it tries to build a video thumbnail.
/// If the video thumbnail fails to load, it returns a generic file type icon.
/// {@endtemplate}
class StreamFileAttachmentThumbnail extends StatelessWidget {
  /// {@macro streamFileAttachmentThumbnail}
  const StreamFileAttachmentThumbnail({
    super.key,
    required this.file,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder = _defaultErrorBuilder,
  });

  /// The file attachment to build the thumbnail for.
  final Attachment file;

  /// The width of the thumbnail.
  final double? width;

  /// The height of the thumbnail.
  final double? height;

  /// How to inscribe the thumbnail into the space allocated during layout.
  final BoxFit? fit;

  /// Builder used when the thumbnail fails to load.
  final ThumbnailErrorBuilder errorBuilder;

  // Default error builder for file attachment thumbnail.
  static Widget _defaultErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    // Return a generic file type icon.
    return getFileTypeImage();
  }

  @override
  Widget build(BuildContext context) {
    final mediaTitle = file.title ?? '';

    // Return a generic file type icon.
    return Image.asset(
      getIconForFile(mediaTitle),
      width: width,
      height: width,
    );
  }
}
