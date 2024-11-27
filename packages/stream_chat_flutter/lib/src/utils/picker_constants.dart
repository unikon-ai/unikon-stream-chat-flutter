import 'package:photo_manager/photo_manager.dart';

/// Constants used for file and gallery picker
class PickerConstants {
  /// Allowed extensions for file picker
  static const allowedExtensionsForFilePicker = [
    'jpeg',
    'jpg',
    'png',
    'gif',
    'bmp',
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
  ];

  /// Allowed file type for gallery picker
  static const allowedRequestTypeForGalleryPicker = RequestType.image;
}
