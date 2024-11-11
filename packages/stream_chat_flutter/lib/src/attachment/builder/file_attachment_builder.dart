part of 'attachment_widget_builder.dart';

/// {@template fileAttachmentBuilder}
/// A widget builder for [AttachmentType.file] attachment type.
/// {@endtemplate}
class FileAttachmentBuilder extends StreamAttachmentWidgetBuilder {
  /// {@macro fileAttachmentBuilder}
  const FileAttachmentBuilder({
    this.shape,
    this.backgroundColor,
    this.constraints = const BoxConstraints(),
    this.padding = const EdgeInsets.all(4),
    this.onAttachmentTap,
    this.showSendingIndicator = true,
  });

  /// The shape of the file attachment.
  final ShapeBorder? shape;

  /// The background color of the file attachment.
  final Color? backgroundColor;

  /// The constraints to apply to the file attachment widget.
  final BoxConstraints constraints;

  /// The padding to apply to the file attachment widget.
  final EdgeInsetsGeometry padding;

  /// The callback to call when the attachment is tapped.
  final StreamAttachmentWidgetTapCallback? onAttachmentTap;

  final bool showSendingIndicator;

  @override
  bool canHandle(
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    final files = attachments[AttachmentType.file];
    return files != null && files.isNotEmpty;
  }

  Future<bool> doesFileExists(Attachment attachment) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${attachment.id}_${attachment.title}';

    final fileExists = await File(filePath).exists();
    return fileExists;
  }

  Future<void> downloadAndOpenAttachment(
      BuildContext context, Attachment attachment) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${attachment.id}_${attachment.title}';

    if (await doesFileExists(attachment)) {
      final result = await OpenFile.open(filePath);
      Fluttertoast.showToast(msg: result.message);
      return;
    } else {
      // If the file does not exist, download it
      final url =
          attachment.assetUrl ?? attachment.imageUrl ?? attachment.thumbUrl;
      if (url == null) {
        Fluttertoast.showToast(msg: 'Attachment URL is not available');
        return;
      }

      try {
        final response = await Dio().download(url, filePath);
        if (response.statusCode == 200) {
          final result = await OpenFile.open(filePath);
          Fluttertoast.showToast(msg: result.message);
        } else {
          Fluttertoast.showToast(msg: 'Failed to download attachment');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error downloading attachment');
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    assert(debugAssertCanHandle(message, attachments), '');

    final files = attachments[AttachmentType.file]!;

    Widget _buildFileAttachment(Attachment file) {
      VoidCallback? onTap;
      if (onAttachmentTap != null) {
        onTap = () => onAttachmentTap!(message, file);
      }

      final isMyMessage =
          message.user?.id == StreamChat.of(context).currentUser!.id;

      return InkWell(
        onTap: () => message.attachments.first.assetUrl != null
            ? downloadAndOpenAttachment(context, file)
            : onTap,
        child: StreamFileAttachment(
          doesFileExists: () => doesFileExists(file),
          onDownloadTap: () => downloadAndOpenAttachment(context, file),
          file: file,
          message: message,
          shape: shape,
          constraints: constraints,
          backgroundColor: backgroundColor,
          internalPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            right: 8,
            bottom: !showSendingIndicator ||
                    !isMyMessage ||
                    message.text?.isNotEmpty == true
                ? 10
                : 0,
          ),
        ),
      );
    }

    Widget child;
    if (files.length == 1) {
      child = _buildFileAttachment(files.first);
    } else {
      child = Column(
        children: <Widget>[
          for (final file in files) _buildFileAttachment(file),
        ].insertBetween(
          // Add a small vertical padding between each attachment.
          SizedBox(height: padding.vertical / 2),
        ),
      );
    }

    return child;
  }
}
