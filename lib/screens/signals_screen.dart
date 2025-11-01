import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../providers/image_provider.dart' as MyImageProvider;
import '../models/user_image_model.dart';
import '../providers/settings_provider.dart';

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreImages();
    }
  }

  void _loadMoreImages() {
    final imageProvider = context.read<MyImageProvider.ImageProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    
    if (settingsProvider.userId != null && 
        !imageProvider.isLoading && 
        imageProvider.hasMore) {
      imageProvider.loadUserImages(settingsProvider.userId!);
    }
  }

  Future<void> _saveImageToGallery(UserImage image) async {
    final imageProvider = context.read<MyImageProvider.ImageProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(width: 12),
              const Text('در حال ذخیره تصویر...'),
            ],
          ),
          duration: const Duration(seconds: 30),
        ),
      );

      final imageBytes = await imageProvider.downloadImage(
        settingsProvider.userId!, 
        image.filename
      );
      
      // ذخیره در پوشه داخلی برنامه
      final directory = await getApplicationDocumentsDirectory();
      final saveDir = Directory('${directory.path}/FirstHiddenBot');
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
                'در حافظه داخلی برنامه',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
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

  void _showDeleteConfirmationDialog(UserImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تصویر'),
        content: const Text('آیا از حذف این تصویر اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteImage(image);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(UserImage image) async {
    final imageProvider = context.read<MyImageProvider.ImageProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    
    final success = await imageProvider.deleteImage(
      settingsProvider.userId!, 
      image.filename
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تصویر حذف شد'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطا در حذف تصویر: ${imageProvider.errorMessage}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showImagePreview(UserImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: PhotoView(
                imageProvider: NetworkImage(
                  'http://178.63.171.244:8000/user/${_currentUserId}/image/${image.filename}'
                ),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(UserImage image) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بخش تصویر
              Expanded(
                child: InkWell(
                  onTap: () => _showImagePreview(image),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      color: Colors.grey.shade100,
                    ),
                    child: Image.network(
                      'http://178.63.171.244:8000/user/${_currentUserId}/image/${image.filename}',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'خطا در بارگذاری',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // اطلاعات تصویر
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          image.pair,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: image.signalType == 'BUY' 
                                ? Colors.green.shade100 
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            image.timeframe,
                            style: TextStyle(
                              fontSize: 10,
                              color: image.signalType == 'BUY' 
                                  ? Colors.green 
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          image.signalType == 'BUY' ? '🟢 BUY' : '🔴 SELL',
                          style: TextStyle(
                            fontSize: 12,
                            color: image.signalType == 'BUY' 
                                ? Colors.green 
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          image.displayTime,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // دکمه‌های action
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                // دکمه ذخیره
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
                const SizedBox(width: 4),
                // دکمه حذف
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => _showDeleteConfirmationDialog(image),
                    tooltip: 'حذف تصویر',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'گالری تصاویر',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'تصاویر سیگنال‌هایی که دریافت می‌کنید در اینجا نمایش داده می‌شوند\n\n'
              'هنوز تصویری دریافت نکرده‌اید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MyImageProvider.ImageProvider imageProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری تصاویر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              imageProvider.errorMessage ?? 'خطای ناشناخته',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              imageProvider.clearError();
              final settingsProvider = context.read<SettingsProvider>();
              if (settingsProvider.userId != null) {
                imageProvider.refreshImages(settingsProvider.userId!);
              }
            },
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<UserImage> images, MyImageProvider.ImageProvider imageProvider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: images.length + 1, // +1 برای loading indicator
      itemBuilder: (context, index) {
        if (index == images.length) {
          if (imageProvider.isLoading && imageProvider.hasMore) {
            return const Center(child: CircularProgressIndicator());
          } else if (!imageProvider.hasMore && images.isNotEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'تمامی تصاویر نمایش داده شد',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
        return _buildImageCard(images[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final imageProvider = Provider.of<MyImageProvider.ImageProvider>(context);
    
    _currentUserId = settingsProvider.userId;

    // بارگذاری اولیه تصاویر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentUserId != null && imageProvider.userImages.isEmpty && !imageProvider.isLoading) {
        imageProvider.refreshImages(_currentUserId!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('گالری تصاویر'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // نشانگر تعداد تصاویر
          if (imageProvider.userImages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${imageProvider.userImages.length} تصویر',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          
          // دکمه refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_currentUserId != null) {
                imageProvider.refreshImages(_currentUserId!);
              }
            },
            tooltip: 'بروزرسانی',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_currentUserId != null) {
            await imageProvider.refreshImages(_currentUserId!);
          }
        },
        child: Column(
          children: [
            // وضعیت بارگذاری
            if (imageProvider.isLoading && imageProvider.userImages.isEmpty)
              const LinearProgressIndicator(),
            
            // بدنه اصلی
            Expanded(
              child: imageProvider.hasError && imageProvider.userImages.isEmpty
                  ? _buildErrorState(imageProvider)
                  : imageProvider.userImages.isEmpty
                      ? _buildEmptyState()
                      : _buildImageGrid(imageProvider.userImages, imageProvider),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
