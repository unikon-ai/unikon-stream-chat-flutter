import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/message_input/clear_input_item_button.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

typedef _Builders = Map<String, QuotedMessageAttachmentThumbnailBuilder>;

/// {@template streamQuotedMessage}
/// Widget for the quoted message.
/// {@endtemplate}
class StreamQuotedMessageWidget extends StatelessWidget {
  /// {@macro streamQuotedMessage}
  const StreamQuotedMessageWidget({
    super.key,
    required this.message,
    required this.messageTheme,
    this.reverse = false,
    this.showBorder = false,
    this.textLimit = 170,
    this.textBuilder,
    this.attachmentThumbnailBuilders,
    this.padding = const EdgeInsets.all(8),
    this.onQuotedMessageClear,
    required this.isMyMessage,
    this.onQuotedMessageCleared,
    this.isReplying = false,
  });

  /// The message
  final Message message;

  /// The message theme
  final StreamMessageThemeData messageTheme;

  /// If true the widget will be mirrored
  final bool reverse;

  /// If true the message will show a grey border
  final bool showBorder;

  /// limit of the text message shown
  final int textLimit;

  /// Map that defines a thumbnail builder for an attachment type
  final _Builders? attachmentThumbnailBuilders;

  /// Padding around the widget
  final EdgeInsetsGeometry padding;

  /// Callback for clearing quoted messages.
  final VoidCallback? onQuotedMessageClear;

  /// {@macro textBuilder}
  final Widget Function(BuildContext, Message)? textBuilder;

  final bool isMyMessage;

  final VoidCallback? onQuotedMessageCleared;

  final bool isReplying;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: padding,
          child: _QuotedMessage(
            message: message,
            textLimit: textLimit,
            messageTheme: messageTheme,
            showBorder: showBorder,
            reverse: reverse,
            textBuilder: textBuilder,
            onQuotedMessageClear: onQuotedMessageClear,
            attachmentThumbnailBuilders: attachmentThumbnailBuilders,
            isMyMessage: isMyMessage,
            isReplying: isReplying,
          ),
        ),
        if (onQuotedMessageCleared != null)
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: onQuotedMessageCleared,
              icon: const Icon(
                Icons.close,
                color: UnikonColorTheme.whiteHintTextColor,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuotedMessage extends StatelessWidget {
  const _QuotedMessage({
    required this.message,
    required this.textLimit,
    required this.messageTheme,
    required this.showBorder,
    required this.reverse,
    this.textBuilder,
    this.onQuotedMessageClear,
    this.attachmentThumbnailBuilders,
    required this.isMyMessage,
    this.isReplying = false,
  });

  final Message message;
  final int textLimit;
  final VoidCallback? onQuotedMessageClear;
  final StreamMessageThemeData messageTheme;
  final bool showBorder;
  final bool reverse;
  final Widget Function(BuildContext, Message)? textBuilder;
  final bool isMyMessage;
  final bool isReplying;

  final _Builders? attachmentThumbnailBuilders;

  bool get _hasAttachments => message.attachments.isNotEmpty;

  bool get _containsText => message.text?.isNotEmpty == true;

  bool get _containsLinkAttachment =>
      message.attachments.any((it) => it.type == AttachmentType.urlPreview);

  bool get _isGiphy => message.attachments
      .any((element) => element.type == AttachmentType.giphy);

  bool get _isDeleted => message.isDeleted || message.deletedAt != null;

  Map<String, String> getAttachmentType(String? title) {
    if (title == null) return {'title': ''};

    final lowerTitle = title.toLowerCase();

    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.tiff',
      '.svg',
      '.heic'
    ];
    final videoExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.flv',
      '.wmv',
      '.webm',
      '.3gp',
      '.m4v'
    ];
    final audioExtensions = [
      '.mp3',
      '.wav',
      '.aac',
      '.flac',
      '.ogg',
      '.wma',
      '.m4a',
      '.alac'
    ];
    final documentExtensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.txt',
      '.odt',
      '.ods',
      '.odp',
      '.rtf'
    ];

    if (imageExtensions.any(lowerTitle.contains)) {
      return {'title': 'Image', 'icon': UnikonColorTheme.imageIcon};
    }
    if (videoExtensions.any(lowerTitle.contains)) {
      return {'title': 'Video', 'icon': UnikonColorTheme.videoIcon};
    }
    if (audioExtensions.any(lowerTitle.contains)) {
      return {'title': 'Voice Message', 'icon': UnikonColorTheme.micIcon};
    }
    if (documentExtensions.any(lowerTitle.contains)) {
      return {'title': 'Document', 'icon': UnikonColorTheme.documentIcon};
    }

    return {'title': ''};
  }

  @override
  Widget build(BuildContext context) {
    final isOnlyEmoji = message.text?.isOnlyEmoji ?? false;
    Message msg = message;

    List<Widget> children = [];

    if (_isDeleted) {
      // Show deleted message text
      children.add(
        Text(
          context.translations.messageDeletedLabel,
          style: messageTheme.messageTextStyle?.copyWith(
            fontStyle: FontStyle.italic,
            color: messageTheme.createdAtStyle?.color,
          ),
        ),
      );
    } else {
      // Show quoted message
      if (!_isGiphy) {
        if (_hasAttachments && !_containsText) {
          final Map<String, String> attachmentMessage =
              getAttachmentType(message.attachments.last.title);
          msg = message.copyWith(text: attachmentMessage['title']);
          if (attachmentMessage['icon'] != null) {
            children
              ..add(
                Image.asset(
                  attachmentMessage['icon']!,
                  width: 16,
                  height: 16,
                ),
              )
              ..add(
                textBuilder?.call(context, msg) ??
                    StreamMessageText(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                      maxLines: 2,
                      message: msg,
                      showReadMore: false,
                      messageTheme: isOnlyEmoji && _containsText
                          ? messageTheme.copyWith(
                              messageTextStyle:
                                  messageTheme.messageTextStyle?.copyWith(
                                fontSize: 32,
                              ),
                            )
                          : messageTheme.copyWith(
                              messageTextStyle:
                                  messageTheme.messageTextStyle?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                    ),
              );
          }
        } else {
          children.add(
            Flexible(
              child: textBuilder?.call(context, msg) ??
                  StreamMessageText(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    maxLines: 2,
                    message: msg,
                    showReadMore: false,
                    messageTheme: isOnlyEmoji && _containsText
                        ? messageTheme.copyWith(
                            messageTextStyle:
                                messageTheme.messageTextStyle?.copyWith(
                              fontSize: 32,
                            ),
                          )
                        : messageTheme.copyWith(
                            messageTextStyle:
                                messageTheme.messageTextStyle?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                  ),
            ),
          );
        }
      }
    }

    // Add clear button if needed.
    if (isDesktopDeviceOrWeb && onQuotedMessageClear != null) {
      children.insert(
        0,
        ClearInputItemButton(onTap: onQuotedMessageClear),
      );
    }

    // Add some spacing between the children.
    children = children.insertBetween(const SizedBox(width: 8));

    return Container(
      decoration: BoxDecoration(
        color: isMyMessage
            ? UnikonColorTheme.replyQuotedMessageBGColor2
            : UnikonColorTheme.replyQuotedMessageBGColor,
        border: const Border(
            left: BorderSide(
          color: UnikonColorTheme.greyColor,
          width: 2,
        )),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      if (message.user != null)
                        Text(
                          isMyMessage ? 'You' : message.user!.name,
                          style: messageTheme.messageTextStyle?.copyWith(
                            color: isMyMessage
                                ? UnikonColorTheme.primaryColor
                                : UnikonColorTheme.messageSentIndicatorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      if (isReplying)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: VerticalDivider(
                                    color: UnikonColorTheme.dividerColor,
                                    thickness: 1,
                                    width: 1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Image.asset(
                                  UnikonColorTheme.replyIcon,
                                ),
                              ),
                              Text(
                                'Replying',
                                style: messageTheme.messageTextStyle?.copyWith(
                                  color: UnikonColorTheme.dividerColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (_hasAttachments)
                  SizedBox(
                    height: 36,
                    child: Center(
                      child: Row(
                        children: children,
                      ),
                    ),
                  )
                else
                  Row(
                    children: children,
                  ),
              ],
            ),
          ),
          if (_hasAttachments)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _ParseAttachments(
                message: message,
                messageTheme: messageTheme,
                attachmentThumbnailBuilders: attachmentThumbnailBuilders,
              ),
            ),
        ],
      ),
    );
  }
}

class _ParseAttachments extends StatelessWidget {
  const _ParseAttachments({
    required this.message,
    required this.messageTheme,
    this.attachmentThumbnailBuilders,
  });

  final Message message;
  final StreamMessageThemeData messageTheme;
  final _Builders? attachmentThumbnailBuilders;

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachments.first;

    var attachmentBuilders = attachmentThumbnailBuilders;
    attachmentBuilders ??= _createDefaultAttachmentBuilders();

    // Build the attachment widget using the builder for the attachment type.
    final attachmentWidget = attachmentBuilders[attachment.type]?.call(
      context,
      attachment,
    );

    // Return empty container if no attachment widget is returned.
    if (attachmentWidget == null) return const SizedBox.shrink();

    final colorTheme = StreamChatTheme.of(context).colorTheme;

    var clipBehavior = Clip.none;
    ShapeDecoration? decoration;
    if (attachment.type != AttachmentType.file) {
      clipBehavior = Clip.hardEdge;
      decoration = ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: colorTheme.borders,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Container(
      key: Key(attachment.id),
      clipBehavior: clipBehavior,
      decoration: decoration,
      constraints: const BoxConstraints.tightFor(width: 45, height: 60),
      child: AbsorbPointer(child: attachmentWidget),
    );
  }

  _Builders _createDefaultAttachmentBuilders() {
    Widget _createMediaThumbnail(BuildContext context, Attachment media) {
      return StreamImageAttachmentThumbnail(
        image: media,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    Widget _createUrlThumbnail(BuildContext context, Attachment media) {
      return StreamImageAttachmentThumbnail(
        image: media,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    Widget _createFileThumbnail(BuildContext context, Attachment file) {
      Widget thumbnail = StreamFileAttachmentThumbnail(
        file: file,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );

      final mediaType = file.title?.mediaType;
      final isImage = mediaType?.type == AttachmentType.image;
      final isVideo = mediaType?.type == AttachmentType.video;
      if (isImage || isVideo) {
        final colorTheme = StreamChatTheme.of(context).colorTheme;
        thumbnail = Container(
          clipBehavior: Clip.hardEdge,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: colorTheme.borders,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: thumbnail,
        );
      }

      return thumbnail;
    }

    return {
      AttachmentType.image: _createMediaThumbnail,
      AttachmentType.giphy: _createMediaThumbnail,
      AttachmentType.video: _createMediaThumbnail,
      AttachmentType.urlPreview: _createUrlThumbnail,
      AttachmentType.file: _createFileThumbnail,
    };
  }
}
