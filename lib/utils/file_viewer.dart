import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lefni/models/document_model.dart';

/// Utility class for opening files in external applications
class FileViewer {
  /// Open a file URL in external application (browser, PDF viewer, etc.)
  static Future<void> openFile(BuildContext context, String fileUrl, [FileType? fileType]) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in browser/external app
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح الملف. يرجى التحقق من الرابط.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء فتح الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open PDF file
  static Future<void> openPdf(BuildContext context, String pdfUrl) async {
    await openFile(context, pdfUrl, FileType.pdf);
  }

  /// Open image file
  static Future<void> openImage(BuildContext context, String imageUrl) async {
    await openFile(context, imageUrl, FileType.image);
  }

  /// Open any file by URL
  static Future<void> openUrl(BuildContext context, String url) async {
    await openFile(context, url);
  }
}
