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

  /// User is currently replying to the message
  final bool isReplying;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        _QuotedMessage(
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
          padding: padding,
        ),
        if (onQuotedMessageCleared != null)
          Positioned(
            right: 4,
            top: 7,
            child: InkWell(
              onTap: onQuotedMessageCleared,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: UnikonTheme.whiteHintTextColor,
                  size: 14,
                ),
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
    this.padding = const EdgeInsets.all(8),
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
  final EdgeInsetsGeometry padding;

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
      return {'title': 'Image', 'icon': UnikonTheme.imageIcon};
    }
    if (videoExtensions.any(lowerTitle.contains)) {
      return {'title': 'Video', 'icon': UnikonTheme.videoIcon};
    }
    if (audioExtensions.any(lowerTitle.contains)) {
      return {'title': 'Voice Message', 'icon': UnikonTheme.micIcon};
    }
    if (documentExtensions.any(lowerTitle.contains)) {
      return {'title': 'Document', 'icon': UnikonTheme.documentIcon};
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
                                fontSize: 20,
                              ),
                            )
                          : messageTheme.copyWith(
                              messageTextStyle:
                                  messageTheme.messageTextStyle?.copyWith(
                                fontSize: 10,
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
                              fontSize: 20,
                            ),
                          )
                        : messageTheme.copyWith(
                            messageTextStyle:
                                messageTheme.messageTextStyle?.copyWith(
                              fontSize: 10,
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
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isMyMessage
            ? UnikonTheme.replyQuotedMessageBGColor2
            : UnikonTheme.replyQuotedMessageBGColor,
        // border: const Border(
        //     left: BorderSide(
        //   color: UnikonColorTheme.greyColor,
        //   width: 2,
        // )),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 3,
            decoration: const BoxDecoration(
              color: UnikonTheme.greyColor,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Padding(
              padding: padding,
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
                                  ? UnikonTheme.primaryColor
                                  : UnikonTheme.messageSentIndicatorColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        if (isReplying)
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: VerticalDivider(
                                    color: UnikonTheme.dividerColor,
                                    thickness: 1,
                                    width: 1,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Image.asset(
                                  height: 12,
                                  width: 12,
                                  UnikonTheme.replyIcon,
                                ),
                              ),
                              Text(
                                'Replying',
                                style: messageTheme.messageTextStyle?.copyWith(
                                  color: UnikonTheme.dividerColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: Center(
                      child: Row(
                        children: children,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_hasAttachments && message.attachments.first.type != 'voicenote')
            Container(
              height: 64,
              width: 44.21,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: UnikonTheme.replyAttachmentBGColor,
              ),
              child: Stack(
                children: [
                  _ParseAttachments(
                    message: message,
                    messageTheme: messageTheme,
                  ),
                  if (message.attachments.first.isVideoAttachment)
                    const Align(
                      child: Icon(
                        Icons.play_circle,
                        size: 12,
                      ),
                    ),
                ],
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: attachmentWidget,
    );
  }

  _Builders _createDefaultAttachmentBuilders() {
    Widget _createMediaThumbnail(BuildContext context, Attachment media) {
      return StreamImageAttachmentThumbnail(
        image: media,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }

    Widget _createUrlThumbnail(BuildContext context, Attachment media) {
      return StreamImageAttachmentThumbnail(
        image: media,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }

    Widget _createFileThumbnail(BuildContext context, Attachment file) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: StreamFileAttachmentThumbnail(
          file: file,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      );
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
