import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// جایگزین کردن تابع _saveImageToGallery
Future<void> _saveImageToGallery(UserImage image) async {
  final imageProvider = context.read<MyImageProvider.ImageProvider>();
  final settingsProvider = context.read<SettingsProvider>();
  
  try {
    // درخواست مجوز
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('دسترسی به حافظه داده نشد')),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 12),
            Text('در حال ذخیره تصویر...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    // دانلود تصویر
    final imageBytes = await imageProvider.downloadImage(
      settingsProvider.userId!, 
      image.filename
    );
    
    // ذخیره در گالری
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(imageBytes),
      quality: 100,
      name: '${image.pair}_${image.timeframe}_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    if (result['isSuccess'] == true) {
      imageProvider.markImageAsSaved(image.filename);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تصویر با موفقیت در گالری ذخیره شد'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ خطا در ذخیره تصویر'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ خطا در ذخیره تصویر: $e'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
