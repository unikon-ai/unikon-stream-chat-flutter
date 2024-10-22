import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/message_input/attachment_preview/attachment_preview_screen.dart';
import 'package:stream_chat_flutter/src/message_input/attachment_preview/gallery_picker_widget.dart';
import 'package:stream_chat_flutter/src/message_input/translucent_scafold.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// @author:Shashi
class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({
    super.key,
    required this.effectiveController,
    required this.channel,
  });
  final StreamMessageInputController effectiveController;
  final Channel channel;

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
          appBar: AppBar(
            backgroundColor: UnikonColorTheme.transparent,
            leading: const UnikonBackButton(),
            title: const Text('Select your file',
                style: TextStyle(
                    color: UnikonColorTheme.messageSentIndicatorColor)),
          ),
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Choose file from your folder',
                      style: TextStyle(color: UnikonColorTheme.dividerColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: BuildMediaAttachment(
                      effectiveController: widget.effectiveController,
                      channel: widget.channel,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Select from your phone gallery',
                          style:
                              TextStyle(color: UnikonColorTheme.dividerColor),
                        ),
                        const Spacer(),
                        Text(
                          '(${selectedIds.length}) Selected',
                          style: const TextStyle(
                              color: UnikonColorTheme.dividerColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GalleryPickerWidget(
                      selectedMediaItems: selectedIds,
                      onMediaItemSelected: (AssetEntity media) async {
                        if (selectedIds.contains(media.id)) {
                          return await attachmentController
                              .removeAssetAttachment(media);
                        }
                        await attachmentController.addAssetAttachment(media);
                      },
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
                          builder: (context) => AttachmentPreviewScreen(
                            attachmentController: attachmentController,
                            effectiveController: widget.effectiveController,
                            channel: widget.channel,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 13),
                      decoration: BoxDecoration(
                          color: UnikonColorTheme.primaryColor,
                          borderRadius: BorderRadius.circular(100)),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: UnikonColorTheme.messageSentIndicatorColor,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}

class BuildMediaAttachment extends StatelessWidget {
  const BuildMediaAttachment({
    super.key,
    required this.effectiveController,
    required this.channel,
  });
  final StreamMessageInputController effectiveController;
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    StreamAttachmentPickerController attachmentController =
        StreamAttachmentPickerController();

    return GestureDetector(
      onTap: () async {
        final pickedFile = await StreamAttachmentHandler.instance.pickFile(
          dialogTitle: 'Select file',
          type: FileType.custom,
          allowedExtensions: [
            'mp4',
            'mov',
            'wmv',
            'avi',
            'flv',
            'mkv',
            'mpeg',
            'webm',
            '3gp',
            'ogg',
            'jpeg',
            'jpg',
            'png',
            'gif',
            'bmp',
            'tiff',
            'svg',
            'pdf',
            'doc',
            'docx',
            'ppt',
            'pptx',
            'xls',
            'xlsx',
            'txt',
            'rtf',
            'odt',
            'ods',
            'odp',
            'epub'
          ],
        );
        if (pickedFile != null) {
          await attachmentController.addAttachment(pickedFile);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AttachmentPreviewScreen(
                attachmentController: attachmentController,
                effectiveController: effectiveController,
                channel: channel,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: UnikonColorTheme.optionsCardBGColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  UnikonColorTheme.folderIcon,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  'Browse your phone',
                  style: TextStyle(
                    color: UnikonColorTheme.messageSentIndicatorColor,
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  'View',
                  style: TextStyle(
                    color: UnikonColorTheme.primaryColor,
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.arrow_forward,
                  color: UnikonColorTheme.primaryColor,
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
