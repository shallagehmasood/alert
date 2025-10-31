import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import '../models/user_image_model.dart';

class ImageProvider with ChangeNotifier {
  List<UserImage> _userImages = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;
  String? _currentUserId;

  List<UserImage> get userImages => _userImages;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  static const String baseUrl = "http://178.63.171.244:8000";
  static const int pageSize = 20;

  Future<void> loadUserImages(String userId, {bool refresh = false}) async {
    if (!refresh && _isLoading) return;
    
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _userImages.clear();
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    _currentUserId = userId;
    
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/images?skip=${_currentPage * pageSize}&limit=$pageSize'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> imagesJson = data['images'];
        
        final newImages = imagesJson.map((json) => UserImage.fromJson(json)).toList();
        
        if (refresh) {
          _userImages = newImages;
        } else {
          _userImages.addAll(newImages);
        }

        _hasMore = newImages.length == pageSize;
        _currentPage++;
        
        print('✅ ${newImages.length} تصویر بارگذاری شد (صفحه $_currentPage)');
      } else {
        throw Exception('خطا در دریافت تصاویر: ${response.statusCode}');
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      print('❌ خطا در بارگذاری تصاویر: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteImage(String userId, String filename) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/$userId/image/$filename'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // حذف از لیست محلی
        _userImages.removeWhere((image) => image.filename == filename);
        notifyListeners();
        print('✅ تصویر حذف شد: $filename');
        return true;
      } else {
        throw Exception('خطا در حذف تصویر: ${response.statusCode}');
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      print('❌ خطا در حذف تصویر: $e');
      notifyListeners();
      return false;
    }
  }

  Future<Uint8List> downloadImage(String userId, String filename) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/image/$filename'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('خطا در دانلود تصویر: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در دانلود تصویر: $e');
      rethrow;
    }
  }

  Future<void> refreshImages(String userId) async {
    await loadUserImages(userId, refresh: true);
  }

  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void markImageAsSaved(String filename) {
    final imageIndex = _userImages.indexWhere((img) => img.filename == filename);
    if (imageIndex != -1) {
      // ایجاد یک شیء جدید با isSavedLocally = true
      final oldImage = _userImages[imageIndex];
      _userImages[imageIndex] = UserImage(
        filename: oldImage.filename,
        pair: oldImage.pair,
        timeframe: oldImage.timeframe,
        signalType: oldImage.signalType,
        modeBits: oldImage.modeBits,
        timestamp: oldImage.timestamp,
        fileSize: oldImage.fileSize,
        created_at: oldImage.created_at,
        isSavedLocally: true,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print('♻️ ImageProvider dispose شد');
    super.dispose();
  }
}
