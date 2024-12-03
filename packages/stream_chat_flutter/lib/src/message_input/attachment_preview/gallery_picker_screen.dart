import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/message_input/attachment_preview/attachment_preview_screen.dart';
import 'package:stream_chat_flutter/src/message_input/attachment_preview/gallery_picker_widget.dart';
import 'package:stream_chat_flutter/src/message_input/translucent_scafold.dart';
import 'package:stream_chat_flutter/src/utils/picker_constants.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// @author:Shashi
class GalleryPickerScreen extends StatefulWidget {
  /// Constructor for creating a [GalleryPickerScreen]
  const GalleryPickerScreen({
    super.key,
    required this.effectiveController,
    required this.channel,
    required this.preMessageCallBack,
    required this.sendOrUpdateMessage,
  });

  final StreamMessageInputController effectiveController;
  final Channel channel;
  final Future<bool> Function()? preMessageCallBack;
  final Future<void> Function({
    required Message message,
  }) sendOrUpdateMessage;

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  StreamAttachmentPickerController attachmentController =
      StreamAttachmentPickerController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: attachmentController,
      builder: (context, value, child) {
        final selectedIds =
            attachmentController.value.map((it) => it.id).toList();
        return TranslucentScaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        UnikonBackButton(),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Select your file',
                          style: TextStyle(
                            color: UnikonTheme.messageSentIndicatorColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Choose file from your folder',
                                style: TextStyle(
                                  color: UnikonTheme.dividerColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: BuildMediaAttachment(
                                effectiveController: widget.effectiveController,
                                channel: widget.channel,
                                preMessageCallBack: widget.preMessageCallBack,
                                sendOrUpdateMessage: widget.sendOrUpdateMessage,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  const Text(
                                    'Select from your phone gallery',
                                    style: TextStyle(
                                        color: UnikonTheme.dividerColor),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '(${selectedIds.length}) Selected',
                                    style: const TextStyle(
                                        color: UnikonTheme.dividerColor),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: GalleryPickerWidget(
                                  selectedMediaItems: selectedIds,
                                  onMediaItemSelected:
                                      (AssetEntity media) async {
                                    if (selectedIds.contains(media.id)) {
                                      return await attachmentController
                                          .removeAssetAttachment(media);
                                    }
                                    await attachmentController
                                        .addAssetAttachment(media);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (attachmentController.value.isNotEmpty)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AttachmentPreviewScreen(
                                      attachmentController:
                                          attachmentController,
                                      effectiveController:
                                          widget.effectiveController,
                                      channel: widget.channel,
                                      preMessageCallBack:
                                          widget.preMessageCallBack,
                                      sendOrUpdateMessage:
                                          widget.sendOrUpdateMessage,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 36, vertical: 13),
                                decoration: BoxDecoration(
                                    color: UnikonTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(100)),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    color:
                                        UnikonTheme.messageSentIndicatorColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A widget that builds the media attachment
class BuildMediaAttachment extends StatelessWidget {
  /// Constructor for creating a [BuildMediaAttachment]
  const BuildMediaAttachment({
    super.key,
    required this.effectiveController,
    required this.channel,
    required this.preMessageCallBack,
    required this.sendOrUpdateMessage,
  });

  final StreamMessageInputController effectiveController;
  final Channel channel;
  final Future<bool> Function()? preMessageCallBack;
  final Future<void> Function({
    required Message message,
  }) sendOrUpdateMessage;

  @override
  Widget build(BuildContext context) {
    StreamAttachmentPickerController attachmentController =
        StreamAttachmentPickerController();

    return GestureDetector(
      onTap: () async {
        final pickedFile = await StreamAttachmentHandler.instance.pickFile(
          dialogTitle: 'Select file',
          type: FileType.custom,
          allowedExtensions: PickerConstants.allowedExtensionsForFilePicker,
        );
        if (pickedFile != null) {
          // Restrict the user to select the video file
          if (pickedFile.isVideo) {
            Fluttertoast.showToast(msg: 'Cant send video attachment');
            return;
          }

          await attachmentController.addAttachment(pickedFile);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AttachmentPreviewScreen(
                attachmentController: attachmentController,
                effectiveController: effectiveController,
                channel: channel,
                preMessageCallBack: preMessageCallBack,
                sendOrUpdateMessage: sendOrUpdateMessage,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: UnikonTheme.optionsCardBGColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  UnikonTheme.folderIcon,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Browse your phone',
                  style: TextStyle(
                    color: UnikonTheme.messageSentIndicatorColor,
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  'View',
                  style: TextStyle(
                    color: UnikonTheme.primaryColor,
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.arrow_forward,
                  color: UnikonTheme.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
