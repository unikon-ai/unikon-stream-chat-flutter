import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'package:open_file/open_file.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/attachment/handler/stream_attachment_handler.dart';
import 'package:stream_chat_flutter/src/attachment/thumbnail/file_attachment_thumbnail.dart';
import 'package:stream_chat_flutter/src/file_downloader/file_downloader_utils.dart';
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

  /// Function to check if the file exists.
  final Future<bool> Function()? doesFileExists;

  /// Callback to call when the download button is tapped.
  final Future<void> Function()? onDownloadTap;

  /// The internal padding of the attachment.
  final EdgeInsetsGeometry internalPadding;

  @override
  State<StreamFileAttachment> createState() => _StreamFileAttachmentState();
}

class _StreamFileAttachmentState extends State<StreamFileAttachment> {
  bool doesFileExists = false;
  final ValueNotifier<double?> _downloadProgress = ValueNotifier(null);

  @override
  void initState() {
    _setDoesFileExists();
    super.initState();
  }

  @override
  void dispose() {
    _downloadProgress.dispose();
    super.dispose();
  }

  /// Set the value of [doesFileExists] by calling the provided function.
  void _setDoesFileExists() async {
    print(await widget.doesFileExists!.call());
    doesFileExists = await widget.doesFileExists!.call() == true;
    if (!context.mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chatTheme = StreamChatTheme.of(context);
    final textTheme = chatTheme.textTheme;
    final colorTheme = chatTheme.colorTheme;
    final isMyMessage =
        widget.message.user?.id == StreamChat.of(context).currentUser!.id;

    final backgroundColor = widget.backgroundColor ??
        ((widget.message.text?.isNotEmpty == true)
            ? (isMyMessage
                ? const Color.fromRGBO(20, 127, 114, 1)
                : const Color.fromRGBO(49, 49, 49, 1))
            : (isMyMessage
                ? chatTheme.ownMessageTheme.messageBackgroundColor
                : chatTheme.otherMessageTheme.messageBackgroundColor));
    final shape = widget.shape ??
        RoundedRectangleBorder(
          side: BorderSide(
            color: colorTheme.borders,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(12),
        );

    return InkWell(
      onTap: widget.onDownloadTap ??
          () async {
            final assetUrl = widget.file.assetUrl;
            final title = widget.file.title;
            if (widget.file.assetUrl != null) {
              // Check if file exists
              final result = await FileDownloaderUtils.doesFileExist(
                  attachmentTitle: widget.file.title!,
                  messageId: widget.message.id);

              // File exists, open it
              if (result) {
                //Open the file
                final filePath = await FileDownloaderUtils.getSavedFilePath(
                    fileName: title!, messageId: widget.message.id);
                final result = await OpenFile.open(filePath);
                Fluttertoast.showToast(msg: result.message);
                return;
              }

              // If not my message, other user has to download it first
              if (!isMyMessage) {
                Fluttertoast.showToast(msg: 'File not downloaded yet');
                return;
              }

              // Download the file
              final downloadResult = await FileDownloaderUtils.downloadFile2(
                url: assetUrl!,
                title: title!,
                isMyMessage: isMyMessage,
                messageId: widget.message.id,
                onDownloadProgress: (p0) {
                  _downloadProgress.value = p0;
                },
              );

              // If download was successful, update the state
              if (downloadResult != null) {
                setState(() {
                  doesFileExists = true;
                });
              }
            }
          },
      child: Container(
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
                    style: textTheme.body.copyWith(
                      color: isMyMessage
                          ? UnikonTheme.messageSentIndicatorColor
                          : colorTheme.textHighEmphasis,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  _FileAttachmentSubtitle(attachment: widget.file),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!doesFileExists && !isMyMessage) ...[
              ValueListenableBuilder(
                valueListenable: _downloadProgress,
                builder: (context, value, child) =>
                    value != null && value > 0 && value < 100
                        ? Text('${value.toStringAsFixed(0)}%')
                        : const SizedBox.shrink(),
              ),
              Material(
                type: MaterialType.transparency,
                child: widget.trailing ??
                    _Trailing(
                      attachment: widget.file,
                      message: widget.message,
                      onDownloadTap: widget.onDownloadTap ??
                          () async {
                            if (_downloadProgress.value != null &&
                                _downloadProgress.value! > 0 &&
                                _downloadProgress.value! < 100) {
                              // File is already downloading
                              return;
                            }

                            FileDownloaderUtils.downloadFile2(
                                    url: widget.file.assetUrl!,
                                    title: '${widget.file.title}',
                                    isMyMessage: isMyMessage,
                                    onDownloadProgress: (p0) {
                                      _downloadProgress.value = p0;
                                    },
                                    messageId: widget.message.id)
                                .then((value) {
                              setState(() {
                                doesFileExists = true;
                              });
                            });
                          },
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget for building file attachment thumbnail.
class FileTypeImage extends StatelessWidget {
  /// Widget for building file attachment thumbnail.
  const FileTypeImage({super.key, required this.file, this.width, this.height});

  /// The file attachment to build the thumbnail for.
  final Attachment file;

  /// The width of the thumbnail.
  final double? width;

  /// The height of the thumbnail.
  final double? height;

  // TODO: Improve image memory.
  // This is using the full image instead of a smaller version (thumbnail)
  @override
  Widget build(BuildContext context) {
    return StreamFileAttachmentThumbnail(
      file: file,
      width: width ?? double.infinity,
      height: width ?? double.infinity,
    );
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
          UnikonTheme.downloadIcon,
          height: 24,
          color: isMyMessage
              ? UnikonTheme.messageSentIndicatorColor
              : UnikonTheme.primaryColor,
        ),
        visualDensity: VisualDensity.compact,
        splashRadius: 16,
        onPressed: onDownloadTap,
      );
    }

    return attachment.uploadState.when(
      preparing: () => const SizedBox.shrink(),
      inProgress: (_, __) => const SizedBox.shrink(),
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
        fontSize: 8,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w300);
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
