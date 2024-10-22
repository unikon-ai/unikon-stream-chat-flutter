import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:stream_chat_flutter/custom_theme/unikon_theme.dart';
import 'package:stream_chat_flutter/src/message_input/attachment_preview/attachment_preview_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Future<void> galleryAndCameraOptionChooser(
    {required BuildContext mainContext,
    required StreamMessageInputController effectiveController}) async {
  String cameraPickOptionIcon =
      "https://application-assets-app-and-web.s3.ap-south-1.amazonaws.com/cameraPick.svg";
  String videoPost =
      "https://application-assets-app-and-web.s3.ap-south-1.amazonaws.com/videoPostIcon.svg";

  showModalBottomSheet(
    backgroundColor: UnikonColorTheme.bottomSheetBGColor,
    context: mainContext,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24, width: 24),
          Container(
            width: 40,
            height: 4,
            decoration: ShapeDecoration(
              color: UnikonColorTheme.whiteHintTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 40, width: 40),
          const Text(
            'Choose one option',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 40, width: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  StreamAttachmentPickerController attachmentController =
                      StreamAttachmentPickerController();

                  final pickedImage = await runInPermissionRequestLock(() {
                    return StreamAttachmentHandler.instance.pickImage(
                      source: image_picker.ImageSource.camera,
                      preferredCameraDevice: image_picker.CameraDevice.rear,
                    );
                  });
                  if (pickedImage != null) {
                    final channel = StreamChannel.of(mainContext).channel;

                    await attachmentController.addAttachment(pickedImage);
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
                child: GalleryOptionChooserWidget(
                  imageLink: cameraPickOptionIcon,
                  label: 'Camera',
                ),
              ),
              const SizedBox(height: 40, width: 40),
              GestureDetector(
                onTap: () async {
                  StreamAttachmentPickerController attachmentController =
                      StreamAttachmentPickerController();

                  final pickedVideo = await runInPermissionRequestLock(() {
                    return StreamAttachmentHandler.instance.pickVideo(
                      source: image_picker.ImageSource.camera,
                      preferredCameraDevice: image_picker.CameraDevice.rear,
                    );
                  });
                  if (pickedVideo != null) {
                    final channel = StreamChannel.of(mainContext).channel;

                    await attachmentController.addAttachment(pickedVideo);
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
                child: GalleryOptionChooserWidget(
                  imageLink: videoPost,
                  label: 'Video',
                ),
              ),
            ],
          ),
          const SizedBox(height: 40, width: 40),
        ],
      );
    },
  );
}

class GalleryOptionChooserWidget extends StatelessWidget {
  final String imageLink;
  final String label;

  const GalleryOptionChooserWidget({
    super.key,
    required this.imageLink,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(colors: [
          UnikonColorTheme.bottomSheetLinearGradientColor1,
          UnikonColorTheme.bottomSheetLinearGradientColor2,
        ]),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 5,
            offset: Offset(0, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkSvgImage(url: imageLink),
          const SizedBox(height: 10, width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}

/// Cache svg network image
class CachedNetworkSvgImage extends StatefulWidget {
  const CachedNetworkSvgImage(
      {super.key,
      this.imageLoadingWidget,
      required this.url,
      this.width,
      this.height,
      this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.placeholderBuilder,
      this.matchTextDirection = false,
      this.allowDrawingOutsideViewBox = false,
      this.semanticsLabel,
      this.excludeFromSemantics = false,
      this.clipBehavior = Clip.hardEdge,
      this.cacheColorFilter = false,
      this.colorFilter,
      this.theme,
      this.color,
      this.colorBlendMode = BlendMode.srcIn,
      this.forceRefresh = false});

  final Widget? imageLoadingWidget;
  final String url;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;
  final WidgetBuilder? placeholderBuilder;
  final bool allowDrawingOutsideViewBox;
  final String? semanticsLabel;
  final Clip clipBehavior;
  final ColorFilter? colorFilter;
  final bool cacheColorFilter;
  final SvgTheme? theme;
  final Color? color;
  final BlendMode colorBlendMode;
  final BoxFit fit;
  final bool matchTextDirection;
  final bool excludeFromSemantics;
  final bool forceRefresh;

  @override
  State<CachedNetworkSvgImage> createState() => _CachedNetworkSvgImageState();
}

class _CachedNetworkSvgImageState extends State<CachedNetworkSvgImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
        future: getImageData(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            File? file = snapshot.data;
            return SvgPicture.file(
              file!,
              width: widget.width,
              alignment: widget.alignment,
              allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
              clipBehavior: widget.clipBehavior,
              excludeFromSemantics: widget.excludeFromSemantics,
              fit: widget.fit,
              height: widget.height,
              key: widget.key,
              matchTextDirection: widget.matchTextDirection,
              placeholderBuilder: widget.placeholderBuilder,
              semanticsLabel: widget.semanticsLabel,
              theme: widget.theme,
              color: widget.color,
            );
          }
          if (widget.imageLoadingWidget != null) {
            return widget.imageLoadingWidget!;
          }

          return const SizedBox.shrink();
        });
  }

  Future<File> getImageData() async {
    late File file;
    if (!widget.forceRefresh) {
      file = await DefaultCacheManager().getSingleFile(widget.url);
    } else {
      var downloadedFile =
          await DefaultCacheManager().downloadFile(widget.url, force: true);
      file = downloadedFile.file;
    }
    return file;
  }
}

mixin CachedNetworkSvgImageManageUtils {
  static void removeFileCache(String url) {
    DefaultCacheManager().removeFile(url).then((value) {
      debugPrint('File removed');
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
    });
  }

  void clearCacheAll() {
    DefaultCacheManager().emptyCache();
  }
}
