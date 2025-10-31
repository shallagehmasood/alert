import 'package:path_provider/path_provider.dart';
import 'dart:io';

// جایگزین کردن تابع _saveImageToGallery
Future<void> _saveImageToGallery(UserImage image) async {
  final imageProvider = context.read<MyImageProvider.ImageProvider>();
  final settingsProvider = context.read<SettingsProvider>();
  
  try {
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
    
    // ذخیره در پوشه Downloads
    final directory = await getDownloadsDirectory();
    final saveDir = Directory('${directory?.path}/FirstHiddenBot');
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }
    
    final fileName = '${image.pair}_${image.timeframe}_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${saveDir.path}/$fileName';
    await File(filePath).writeAsBytes(imageBytes);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    imageProvider.markImageAsSaved(image.filename);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✅ تصویر با موفقیت ذخیره شد'),
            Text(
              'مسیر: FirstHiddenBot/$fileName',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
    
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

// همچنین در _buildImageCard، آیکون ذخیره را به این صورت تغییر دهید:
Container(
  decoration: BoxDecoration(
    color: Colors.black54,
    shape: BoxShape.circle,
  ),
  child: IconButton(
    icon: Icon(
      image.isSavedLocally ? Icons.check : Icons.save_alt,
      color: Colors.white,
      size: 18,
    ),
    onPressed: image.isSavedLocally 
        ? null 
        : () => _saveImageToGallery(image),
    tooltip: 'ذخیره در حافظه',
  ),
),
