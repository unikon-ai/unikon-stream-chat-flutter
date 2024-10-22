import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';

import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// WidgetBuilder used to build the message input attachment list.
///
/// see more:
///   - [StreamMessageInputAttachmentList]
typedef AttachmentListBuilder = Widget Function(
  BuildContext context,
  List<Attachment> attachments,
  ValueSetter<Attachment>? onRemovePressed,
);

/// WidgetBuilder used to build the message input attachment item.
///
/// see more:
///  - [StreamMessageInputAttachmentList]
typedef AttachmentItemBuilder = Widget Function(
  BuildContext context,
  Attachment attachment,
  ValueSetter<Attachment>? onRemovePressed,
);

/// {@template stream_message_input_attachment_list}
/// Widget used to display the list of attachments added to the message input.
///
/// By default, it displays the list of file attachments and media attachments
/// separately.
///
/// You can customize the list of file attachments and media attachments using
/// [fileAttachmentListBuilder] and [mediaAttachmentListBuilder] respectively.
///
/// You can also customize the attachment item using [fileAttachmentBuilder] and
/// [mediaAttachmentBuilder] respectively.
///
/// You can override the default action of removing an attachment by providing
/// [onRemovePressed].
/// {@endtemplate}
class StreamMessageInputAttachmentList extends StatefulWidget {
  /// {@macro stream_message_input_attachment_list}
  const StreamMessageInputAttachmentList({
    super.key,
    required this.attachments,
    this.onRemovePressed,
    this.fileAttachmentBuilder,
    this.mediaAttachmentBuilder,
    this.fileAttachmentListBuilder,
    this.mediaAttachmentListBuilder,
  });

  /// List of attachments to display thumbnails for.
  ///
  /// Open graph should be filtered out.
  final Iterable<Attachment> attachments;

  /// Builder used to build the file attachment item.
  final AttachmentItemBuilder? fileAttachmentBuilder;

  /// Builder used to build the media attachment item.
  final AttachmentItemBuilder? mediaAttachmentBuilder;

  /// Builder used to build the file attachment list.
  final AttachmentListBuilder? fileAttachmentListBuilder;

  /// Builder used to build the media attachment list.
  final AttachmentListBuilder? mediaAttachmentListBuilder;

  /// Callback called when the remove button is pressed.
  final ValueSetter<Attachment>? onRemovePressed;

  @override
  State<StreamMessageInputAttachmentList> createState() =>
      _StreamMessageInputAttachmentListState();
}

class _StreamMessageInputAttachmentListState
    extends State<StreamMessageInputAttachmentList> {
  List<Attachment> fileAttachments = [];
  List<Attachment> mediaAttachments = [];

  void _updateAttachments() {
    // Clear the lists.
    fileAttachments.clear();
    mediaAttachments.clear();

    // Split the attachments into file and media attachments.
    for (final attachment in widget.attachments) {
      if (attachment.type == AttachmentType.file) {
        fileAttachments.add(attachment);
      } else {
        mediaAttachments.add(attachment);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _updateAttachments();
  }

  @override
  void didUpdateWidget(covariant StreamMessageInputAttachmentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachments != widget.attachments) {
      _updateAttachments();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there are no attachments, return an empty box.
    if (fileAttachments.isEmpty && mediaAttachments.isEmpty) {
      return const SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (mediaAttachments.isNotEmpty)
          Flexible(
            child: MessageInputMediaAttachments(
              attachments: mediaAttachments,
              attachmentBuilder: widget.mediaAttachmentBuilder,
              onRemovePressed: widget.onRemovePressed,
            ),
          ),
        if (fileAttachments.isNotEmpty)
          Flexible(
            child: MessageInputFileAttachments(
              attachments: fileAttachments,
              attachmentBuilder: widget.fileAttachmentBuilder,
              onRemovePressed: widget.onRemovePressed,
            ),
          ),
      ],
    );
  }
}

/// Widget used to display the list of file type attachments added to the
/// message input.
class MessageInputFileAttachments extends StatelessWidget {
  /// Creates a new FileAttachments widget.
  const MessageInputFileAttachments({
    super.key,
    required this.attachments,
    this.attachmentBuilder,
    this.onRemovePressed,
  });

  /// List of file type attachments to display thumbnails for.
  final List<Attachment> attachments;

  /// Builder used to build the file type attachment item.
  final AttachmentItemBuilder? attachmentBuilder;

  /// Callback called when the remove button is pressed.
  final ValueSetter<Attachment>? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: PageView(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        children: attachments.reversed.map<Widget>(
          (attachment) {
            // If a custom builder is provided, use it.
            final builder = attachmentBuilder;
            if (builder != null) {
              return builder(context, attachment, onRemovePressed);
            }

            // Otherwise, use the default builder.
            return StreamStorageMediaAttachmentBuilder(
              attachment: attachment,
              onRemovePressed: onRemovePressed,
            );
          },
        ).toList(),
      ),
    );
  }
}

/// Widget used to display the list of media type attachments added to the
/// message input.
class MessageInputMediaAttachments extends StatefulWidget {
  /// Creates a new MediaAttachments widget.
  const MessageInputMediaAttachments({
    super.key,
    required this.attachments,
    this.attachmentBuilder,
    this.onRemovePressed,
  });

  /// List of media type attachments to display thumbnails for.
  ///
  /// Only attachments of type `image`, `video` and `giphy` are supported. Shows
  /// a placeholder for other types of attachments.
  final List<Attachment> attachments;

  /// Builder used to build the media type attachment item.
  final AttachmentItemBuilder? attachmentBuilder;

  /// Callback called when the remove button is pressed.
  final ValueSetter<Attachment>? onRemovePressed;

  @override
  State<MessageInputMediaAttachments> createState() =>
      _MessageInputMediaAttachmentsState();
}

class _MessageInputMediaAttachmentsState
    extends State<MessageInputMediaAttachments> {
  PageController pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: PageView(
              controller: pageViewController,
              children: widget.attachments.map<Widget>(
                (attachment) {
                  // If a custom builder is provided, use it.
                  final builder = widget.attachmentBuilder;
                  if (builder != null) {
                    return builder(context, attachment, widget.onRemovePressed);
                  }

                  if (attachment.type == AttachmentType.video) {
                    return StreamVideoMediaAttachmentBuilder(
                      attachment: attachment,
                      onRemovePressed: widget.onRemovePressed,
                    );
                  } else {
                    return StreamMediaAttachmentBuilder(
                      attachment: attachment,
                      onRemovePressed: widget.onRemovePressed,
                    );
                  }
                },
              ).toList()),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height *
              0.1, // Adjust height to make the thumbnails larger
          child: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final Attachment attachment = widget.attachments[index];
              return GestureDetector(
                onTap: () {
                  pageViewController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: StreamMediaAttachmentThumbnail(
                        media: attachment,
                        width: 60, // Adjusted width to be larger
                        height: 80, // Adjusted height to be larger
                        fit: BoxFit
                            .cover, // Fit type can be adjusted as per need
                      ),
                    ),
                    if (attachment.type == AttachmentType.video)
                      const Icon(
                        Icons.play_circle,
                        size: 24,
                      )
                  ],
                ),
              );
            },
            itemCount: widget.attachments.length,
          ),
        ),
      ],
    );
  }
}

/// Widget used to display a media type attachment item.
class StreamStorageMediaAttachmentBuilder extends StatelessWidget {
  /// Creates a new media attachment item.
  const StreamStorageMediaAttachmentBuilder(
      {super.key, required this.attachment, this.onRemovePressed});

  /// The media attachment to display.
  final Attachment attachment;

  /// Callback called when the remove button is pressed.
  final ValueSetter<Attachment>? onRemovePressed;

  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    const int tb = gb * 1024;

    if (bytes < kb) {
      return '$bytes B';
    } else if (bytes < mb) {
      return '${(bytes / kb).toStringAsFixed(2)} KB';
    } else if (bytes < gb) {
      return '${(bytes / mb).toStringAsFixed(2)} MB';
    } else if (bytes < tb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else {
      return '${(bytes / tb).toStringAsFixed(2)} TB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = StreamChatTheme.of(context).colorTheme;
    final shape = RoundedRectangleBorder(
      side: BorderSide(
        color: colorTheme.borders,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.circular(14),
    );

    return Container(
      key: Key(attachment.id),
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(shape: shape),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: FileTypeImage(
                    file: attachment,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (attachment.title != null)
                  Text(
                    attachment.title!,
                    style: const TextStyle(
                      color: UnikonColorTheme.messageSentIndicatorColor,
                    ),
                  ),
                const SizedBox(
                  height: 4,
                ),
                if (attachment.fileSize != null)
                  Text(
                    formatFileSize(attachment.fileSize!),
                    style: const TextStyle(
                      color: UnikonColorTheme.messageSentIndicatorColor,
                    ),
                  )
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: RemoveAttachmentButton(
                onPressed: onRemovePressed != null
                    ? () => onRemovePressed!(attachment)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget used to display a media type attachment item.
class StreamMediaAttachmentBuilder extends StatelessWidget {
  /// Creates a new media attachment item.
  const StreamMediaAttachmentBuilder(
      {super.key, required this.attachment, this.onRemovePressed});

  /// The media attachment to display.
  final Attachment attachment;

  /// Callback called when the remove button is pressed.
  final ValueSetter<Attachment>? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final colorTheme = StreamChatTheme.of(context).colorTheme;
    final shape = RoundedRectangleBorder(
      side: BorderSide(
        color: colorTheme.borders,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.circular(14),
    );

    return Container(
      key: Key(attachment.id),
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(shape: shape),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            StreamMediaAttachmentThumbnail(
              media: attachment,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: RemoveAttachmentButton(
                onPressed: onRemovePressed != null
                    ? () => onRemovePressed!(attachment)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Material Button used for removing attachments.
class RemoveAttachmentButton extends StatelessWidget {
  /// Creates a new remove attachment button.
  const RemoveAttachmentButton({super.key, this.onPressed});

  /// Callback when the remove attachment button is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: RawMaterialButton(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.close,
          size: 24,
          color: UnikonColorTheme.dividerColor,
        ),
      ),
    );
  }
}

class StreamVideoMediaAttachmentBuilder extends StatefulWidget {
  /// Creates a new media attachment item.
  const StreamVideoMediaAttachmentBuilder(
      {super.key, required this.attachment, this.onRemovePressed});

  /// The media attachment to display.
  final Attachment attachment;

  /// Callback called when the remove button is pressed.
  final ValueSetter<Attachment>? onRemovePressed;

  @override
  State<StreamVideoMediaAttachmentBuilder> createState() =>
      _StreamVideoMediaAttachmentBuilderState();
}

class _StreamVideoMediaAttachmentBuilderState
    extends State<StreamVideoMediaAttachmentBuilder> {
  late final VideoPackage controller;
  bool isPlaying = false;
  @override
  void initState() {
    controller = VideoPackage(
      widget.attachment,
      showControls: true,
    );
    super.initState();
    initializePlayers();
  }

  Future<void> initializePlayers() async {
    await controller.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = StreamChatTheme.of(context).colorTheme;
    final shape = RoundedRectangleBorder(
      side: BorderSide(
        color: colorTheme.borders,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      borderRadius: BorderRadius.circular(14),
    );
    if (widget.attachment.type == AttachmentType.video &&
        !controller.initialized) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    return Container(
      key: Key(widget.attachment.id),
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(shape: shape),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (!isPlaying)
              Stack(
                children: [
                  StreamMediaAttachmentThumbnail(
                    media: widget.attachment,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPlaying = true;
                      });
                      controller.chewieController?.play();
                    },
                    child: const Center(
                      child: Icon(
                        Icons.play_circle,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              )
            else
              Chewie(
                controller: controller.chewieController!,
              ),
            Positioned(
              top: 8,
              right: 8,
              child: RemoveAttachmentButton(
                onPressed: widget.onRemovePressed != null
                    ? () => widget.onRemovePressed!(widget.attachment)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
