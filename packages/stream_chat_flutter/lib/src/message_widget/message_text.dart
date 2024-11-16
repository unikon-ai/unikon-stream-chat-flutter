import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@template streamMessageText}
/// The text content of a message.
/// {@endtemplate}
class StreamMessageText extends StatefulWidget {
  /// {@macro streamMessageText}
  const StreamMessageText({
    super.key,
    required this.message,
    required this.messageTheme,
    this.onMentionTap,
    this.onLinkTap,
    this.maxLines = 5,
    this.showReadMore = true,
    this.isMyMessage,
    this.maxWidth = 250,
  });

  /// Message whose text is to be displayed
  final Message message;

  /// The action to perform when a mention is tapped
  final void Function(User)? onMentionTap;

  /// The action to perform when a link is tapped
  final void Function(String)? onLinkTap;

  /// [StreamMessageThemeData] whose text theme is to be applied
  final StreamMessageThemeData messageTheme;

  final int maxLines;

  final bool showReadMore;

  final bool? isMyMessage;

  final double maxWidth;
  @override
  State<StreamMessageText> createState() => _StreamMessageTextState();
}

class _StreamMessageTextState extends State<StreamMessageText> {
  String? messageText;
  String truncatedMessageText = '';
  bool showFullText = false;

  String getTruncatedText({
    required String text,
    required double maxWidth,
  }) {
    // Set up the text painter to measure the text
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: widget.messageTheme.messageTextStyle),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    // If the text doesn't exceed maxLines, return the full text
    if (!textPainter.didExceedMaxLines) {
      return text;
    }

    // Find the point at which the text needs to be truncated
    var endIndex = textPainter
        .getPositionForOffset(Offset(maxWidth, textPainter.height))
        .offset;
    var trimmedText = text.substring(0, endIndex);

    // Try adding "Read more..." and ensure it doesn't overflow
    while (true) {
      final testText = trimmedText;
      final testPainter = TextPainter(
        text: TextSpan(
            text: testText, style: widget.messageTheme.messageTextStyle),
        maxLines: widget.maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);

      if (testPainter.didExceedMaxLines) {
        trimmedText = trimmedText.substring(0, trimmedText.length + 12);
      } else {
        break;
      }
    }

    return trimmedText;
  }

  @override
  Widget build(BuildContext context) {
    final streamChat = StreamChat.of(context);
    assert(streamChat.currentUser != null, '');
    return BetterStreamBuilder<String>(
      stream: streamChat.currentUserStream.map((it) => it!.language ?? 'en'),
      initialData: streamChat.currentUser!.language ?? 'en',
      builder: (context, language) {
        messageText =
            widget.message.translate(language).replaceMentions().text?.trim();
        if (messageText != null) {
          truncatedMessageText =
              getTruncatedText(text: messageText!, maxWidth: widget.maxWidth);
        }
        final themeData = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MarkdownBody(
              data: messageText != null &&
                      (messageText!.length == truncatedMessageText.length ||
                          showFullText)
                  ? messageText!.replaceAll('\n', '\n\n')
                  : truncatedMessageText.replaceAll('\n', '\n\n'),
              selectable: isDesktopDeviceOrWeb,
              onTapText: () {},
              onSelectionChanged: (val, selection, cause) {},
              onTapLink: (
                String link,
                String? href,
                String title,
              ) {
                if (link.startsWith('@')) {
                  final mentionedUser =
                      widget.message.mentionedUsers.firstWhereOrNull(
                    (u) => '@${u.name}' == link,
                  );

                  if (mentionedUser == null) return;

                  widget.onMentionTap?.call(mentionedUser);
                } else {
                  if (widget.onLinkTap != null) {
                    widget.onLinkTap!(link);
                  } else {
                    launchURL(context, link);
                  }
                }
              },
              styleSheet: MarkdownStyleSheet.fromTheme(
                themeData.copyWith(
                  textTheme: themeData.textTheme.apply(
                    bodyColor: widget.messageTheme.messageTextStyle?.color,
                    decoration:
                        widget.messageTheme.messageTextStyle?.decoration,
                    decorationColor:
                        widget.messageTheme.messageTextStyle?.decorationColor,
                    decorationStyle:
                        widget.messageTheme.messageTextStyle?.decorationStyle,
                    fontFamily:
                        widget.messageTheme.messageTextStyle?.fontFamily,
                  ),
                ),
              ).copyWith(
                a: widget.messageTheme.messageLinksStyle,
                p: widget.messageTheme.messageTextStyle,
              ),
            ),
            if (widget.showReadMore &&
                showFullText != true &&
                messageText!.length > truncatedMessageText.length)
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFullText = !showFullText;
                  });
                },
                child: Text(
                  'Read more...',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isMyMessage == true
                        ? UnikonColorTheme.messageSentIndicatorColor
                        : UnikonColorTheme.primaryColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
