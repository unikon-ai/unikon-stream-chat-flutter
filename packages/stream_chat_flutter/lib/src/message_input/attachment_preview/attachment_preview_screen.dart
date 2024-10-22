import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/message_input/translucent_scafold.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AttachmentPreviewScreen extends StatefulWidget {
  const AttachmentPreviewScreen({
    super.key,
    required this.effectiveController,
    required this.attachmentController,
    required this.channel,
  });
  final StreamMessageInputController effectiveController;
  final StreamAttachmentPickerController attachmentController;
  final Channel channel;

  /// Callback called when the remove button is pressed.

  @override
  State<AttachmentPreviewScreen> createState() =>
      _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
  Future<void> _onAttachmentRemovePressed(Attachment attachment) async {
    final file = attachment.file;
    final uploadState = attachment.uploadState;

    if (file != null && !uploadState.isSuccess && !isWeb) {
      await StreamAttachmentHandler.instance.deleteAttachmentFile(
        attachmentFile: file,
      );
    }

    await widget.attachmentController.removeAttachment(attachment);
    if (widget.attachmentController.value.isEmpty) {
      Navigator.of(context).pop();
    }

    if (mounted) setState(() {});
  }

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final nonOGAttachments = widget.attachmentController.value.where((it) {
      return it.titleLink == null;
    }).toList(growable: false);

    // If there are no attachments, return an empty widget
    if (nonOGAttachments.isEmpty) return const Offstage();

    // Otherwise, use the default attachment list builder.
    return StreamChannel(
      channel: widget.channel,
      child: GestureDetector(
        onTap: () {
          if (focusNode.hasFocus) {
            focusNode.unfocus();
          }
        },
        child: TranslucentScaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                AttachmentPreviewAppbar(widget: widget),
                const SizedBox(
                  height: 40,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: StreamMessageInputAttachmentList(
                      attachments: nonOGAttachments,
                      onRemovePressed: _onAttachmentRemovePressed,
                    ),
                  ),
                ),

                // Padding ensures the input field doesn't overlap with the keyboard
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: BuildTextInputWidget(
                    nonOGAttachments: nonOGAttachments,
                    focusNode: focusNode,
                    channel: widget.channel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AttachmentPreviewAppbar extends StatelessWidget {
  const AttachmentPreviewAppbar({
    super.key,
    required this.widget,
  });

  final AttachmentPreviewScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const UnikonBackButton(),
          if (widget.attachmentController.value.first.type !=
              AttachmentType.file)
            Text(
              '${widget.attachmentController.value.length} media selected',
              style: const TextStyle(color: UnikonColorTheme.dividerColor),
            ),
        ],
      ),
    );
  }
}

class UnikonBackButton extends StatelessWidget {
  const UnikonBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              UnikonColorTheme.backButtonLinearGradientColor1,
              UnikonColorTheme.backButtonLinearGradientColor2
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class BuildTextInputWidget extends StatefulWidget {
  const BuildTextInputWidget({
    super.key,
    required this.nonOGAttachments,
    required this.focusNode,
    required this.channel,
  });
  final List<Attachment> nonOGAttachments;
  final FocusNode focusNode;
  final Channel channel;
  @override
  State<BuildTextInputWidget> createState() => _BuildTextInputWidgetState();
}

class _BuildTextInputWidgetState extends State<BuildTextInputWidget> {
  final StreamMessageInputController messageInputController =
      StreamMessageInputController();
  late StreamMessageInputThemeData _messageInputTheme;

  @override
  void initState() {
    messageInputController.addListener(() {
      if (mounted &&
          [0, 1].contains(messageInputController.text.trim().length)) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _messageInputTheme = StreamMessageInputTheme.of(context);
    super.didChangeDependencies();
  }

  InputDecoration _getInputDecoration(BuildContext context) {
    return InputDecoration(
      isDense: true,
      hintText: 'Type your message...',
      hintStyle: _messageInputTheme.inputTextStyle!.copyWith(
        color: UnikonColorTheme.messageInputHintColor,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 13, 11),
      suffixIconConstraints: const BoxConstraints.tightFor(height: 40),
      prefixIconConstraints: const BoxConstraints.tightFor(height: 40),
    );
  }

  Future<void> _sendMessage(List<Attachment> nonOGAttachments) async {
    widget.channel.sendMessage(
      Message(
        text: messageInputController.text.trim().isEmpty
            ? null
            : messageInputController.text.trim(),
        attachments: nonOGAttachments,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double borderRadius = messageInputController.text.trim().isNotEmpty
        ? UnikonColorTheme.focusTextfieldBorderRadius
        : UnikonColorTheme.unfocusTextfieldBorderRadius;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: UnikonColorTheme.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            Flexible(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: UnikonColorTheme.messageSentIndicatorColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: StreamMessageTextField(
                  key: const Key('messageInputText'),
                  onSubmitted: (_) => _sendMessage(widget.nonOGAttachments),
                  controller: messageInputController,
                  focusNode: widget.focusNode,
                  style: _messageInputTheme.inputTextStyle?.copyWith(
                    color: UnikonColorTheme.messageInputHintColor,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: _getInputDecoration(context),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            StreamMessageSendButton(
              onSendMessage: () => _sendMessage(widget.nonOGAttachments),
              isIdle: false,
            )
          ],
        ),
      ),
    );
  }
}
