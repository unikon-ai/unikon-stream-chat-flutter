import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/attachment/handler/stream_attachment_handler.dart';
import 'package:stream_chat_flutter/src/attachment/thumbnail/file_attachment_thumbnail.dart';
import 'package:stream_chat_flutter/src/indicators/upload_progress_indicator.dart';
import 'package:stream_chat_flutter/src/misc/stream_svg_icon.dart';
import 'package:stream_chat_flutter/src/stream_chat.dart';
import 'package:stream_chat_flutter/src/theme/stream_chat_theme.dart';
import 'package:stream_chat_flutter/src/utils/utils.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

/// {@template streamFileAttachment}
/// Displays file attachments that have been sent in a chat.
///
/// Used in [MessageWidget].
/// {@endtemplate}
class StreamFileAttachment extends StatefulWidget {
  /// {@macro streamFileAttachment}
  const StreamFileAttachment({
    super.key,
    required this.message,
    required this.file,
    this.title,
    this.trailing,
    this.shape,
    this.backgroundColor,
    this.constraints = const BoxConstraints(),
    this.onDownloadTap,
    this.doesFileExists,
    this.internalPadding = const EdgeInsets.all(8),
  });

  /// The [Message] that the file is attached to.
  final Message message;

  /// The [Attachment] object containing the file information.
  final Attachment file;

  /// The shape of the attachment.
  ///
  /// Defaults to [RoundedRectangleBorder] with a radius of 12.
  final ShapeBorder? shape;

  /// The background color of the attachment.
  ///
  /// Defaults to [StreamChatTheme.colorTheme.barsBg].
  final Color? backgroundColor;

  /// The constraints to use when displaying the file.
  final BoxConstraints constraints;

  /// Widget for displaying the title of the attachment.
  /// (usually the file name)
  final Widget? title;

  /// Widget for displaying at the end of the attachment.
  /// (such as a download button)
  final Widget? trailing;

  final Future<bool> Function()? doesFileExists;

  final Future<void> Function()? onDownloadTap;

  final EdgeInsetsGeometry internalPadding;
  @override
  State<StreamFileAttachment> createState() => _StreamFileAttachmentState();
}

class _StreamFileAttachmentState extends State<StreamFileAttachment> {
  bool doesFileExists = false;
  @override
  void initState() {
    setDoesFileExists();
    super.initState();
  }

  setDoesFileExists() async {
    print(await widget.doesFileExists!.call());
    doesFileExists = await widget.doesFileExists!.call() == true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chatTheme = StreamChatTheme.of(context);
    final textTheme = chatTheme.textTheme;
    final colorTheme = chatTheme.colorTheme;
    final isMyMessage =
        widget.message.user?.id == StreamChat.of(context).currentUser!.id;

    final backgroundColor = this.widget.backgroundColor ??
        ((widget.message.text?.isNotEmpty == true)
            ? (isMyMessage
                ? const Color.fromRGBO(20, 127, 114, 1)
                : const Color.fromRGBO(49, 49, 49, 1))
            : (isMyMessage
                ? chatTheme.ownMessageTheme.messageBackgroundColor
                : chatTheme.otherMessageTheme.messageBackgroundColor));
    final shape = this.widget.shape ??
        RoundedRectangleBorder(
          side: BorderSide(
            color: colorTheme.borders,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(12),
        );

    return Container(
      padding: widget.internalPadding,
      constraints: widget.constraints,
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        shape: shape,
        color: backgroundColor,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            height: 40,
            child: FileTypeImage(file: widget.file),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file.title ?? context.translations.fileText,
                  maxLines: 1,
                  style: textTheme.bodyBold.copyWith(
                    color: isMyMessage
                        ? UnikonColorTheme.messageSentIndicatorColor
                        : colorTheme.textHighEmphasis,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                _FileAttachmentSubtitle(attachment: widget.file),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!doesFileExists)
            Material(
              type: MaterialType.transparency,
              child: widget.trailing ??
                  _Trailing(
                    attachment: widget.file,
                    message: widget.message,
                    onDownloadTap: widget.onDownloadTap,
                  ),
            ),
        ],
      ),
    );
  }
}

class FileTypeImage extends StatelessWidget {
  const FileTypeImage({required this.file});

  final Attachment file;

  // TODO: Improve image memory.
  // This is using the full image instead of a smaller version (thumbnail)
  @override
  Widget build(BuildContext context) {
    Widget child = StreamFileAttachmentThumbnail(
      file: file,
      width: double.infinity,
      height: double.infinity,
    );

    final mediaType = file.title?.mediaType;
    final isImage = mediaType?.type == AttachmentType.image;
    final isVideo = mediaType?.type == AttachmentType.video;
    if (isImage || isVideo) {
      final colorTheme = StreamChatTheme.of(context).colorTheme;
      child = Container(
        clipBehavior: Clip.hardEdge,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: child,
      );
    }

    return child;
  }
}

class _Trailing extends StatelessWidget {
  _Trailing({
    required this.attachment,
    required this.message,
    required this.onDownloadTap,
  });

  final Attachment attachment;
  final Message message;
  final Future<void> Function()? onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final theme = StreamChatTheme.of(context);
    final channel = StreamChannel.of(context).channel;
    final attachmentId = attachment.id;
    bool isMyMessage =
        message.user?.id == StreamChat.of(context).currentUser?.id;

    if (message.state.isCompleted) {
      return IconButton(
        icon: Image.asset(
          UnikonColorTheme.downloadIcon,
          height: 24,
          color: isMyMessage
              ? UnikonColorTheme.messageSentIndicatorColor
              : UnikonColorTheme.primaryColor,
        ),
        visualDensity: VisualDensity.compact,
        splashRadius: 16,
        onPressed: onDownloadTap,
      );
    }

    return attachment.uploadState.when(
      preparing: () => Padding(
        padding: const EdgeInsets.all(8),
        child: _TrailingButton(
          icon: StreamSvgIcon.close(color: theme.colorTheme.barsBg),
          fillColor: theme.colorTheme.overlayDark,
          onPressed: () => channel.cancelAttachmentUpload(attachmentId),
        ),
      ),
      inProgress: (_, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: _TrailingButton(
          icon: StreamSvgIcon.close(color: theme.colorTheme.barsBg),
          fillColor: theme.colorTheme.overlayDark,
          onPressed: () => channel.cancelAttachmentUpload(attachmentId),
        ),
      ),
      success: () => Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: theme.colorTheme.accentPrimary,
          maxRadius: 12,
          child: StreamSvgIcon.check(color: theme.colorTheme.barsBg),
        ),
      ),
      failed: (_) => Padding(
        padding: const EdgeInsets.all(8),
        child: _TrailingButton(
          icon: StreamSvgIcon.retry(color: theme.colorTheme.barsBg),
          fillColor: theme.colorTheme.overlayDark,
          onPressed: () => channel.retryAttachmentUpload(
            message.id,
            attachmentId,
          ),
        ),
      ),
    );
  }
}

class _TrailingButton extends StatelessWidget {
  const _TrailingButton({
    this.onPressed,
    this.fillColor,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Color? fillColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: RawMaterialButton(
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        onPressed: onPressed,
        fillColor: fillColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: icon,
      ),
    );
  }
}

class _FileAttachmentSubtitle extends StatelessWidget {
  const _FileAttachmentSubtitle({
    required this.attachment,
  });

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final theme = StreamChatTheme.of(context);
    final size = attachment.file?.size ?? attachment.extraData['file_size'];
    final textStyle = theme.textTheme.footnote.copyWith(
      color: Colors.white,
    );
    return attachment.uploadState.when(
      preparing: () => Text(fileSize(size), style: textStyle),
      inProgress: (sent, total) => StreamUploadProgressIndicator(
        uploaded: sent,
        total: total,
        textStyle: textStyle,
        progressIndicatorColor: theme.colorTheme.textHighEmphasis,
      ),
      success: () => Text(fileSize(size), style: textStyle),
      failed: (_) => Text(
        context.translations.uploadErrorLabel,
        style: textStyle,
      ),
    );
  }
}
