import 'dart:io';
import 'package:flutter/material.dart';

/// Image helper utility functions
/// Centralized image handling logic
class ImageHelper {
  // Private constructor to prevent instantiation
  ImageHelper._();

  /// Clean image path by removing file:// prefix
  static String cleanPath(String path) {
    if (path.startsWith('file://')) {
      return path.substring(7);
    }
    return path;
  }

  /// Check if path is a network URL
  static bool isNetworkPath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Check if path is an asset path
  static bool isAssetPath(String path) {
    return path.startsWith('assets/');
  }

  /// Check if file exists
  static bool fileExists(String path) {
    try {
      final cleanedPath = cleanPath(path);
      final file = File(cleanedPath);
      return file.existsSync();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }

  /// Build image widget from path
  /// Automatically determines if it's a file, network, or asset image
  static Widget buildImage({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    Widget? placeholder,
  }) {
    // Default error widget
    final defaultErrorWidget = errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 48,
          ),
        );

    // Check if it's an asset image
    if (isAssetPath(path)) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading asset image: $error');
          return defaultErrorWidget;
        },
      );
    }

    // Check if it's a network image
    if (isNetworkPath(path)) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: placeholder != null
            ? (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder;
              }
            : null,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading network image: $error');
          return defaultErrorWidget;
        },
      );
    }

    // Try as file image
    try {
      final cleanedPath = cleanPath(path);
      final file = File(cleanedPath);

      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading file image: $error');
            return defaultErrorWidget;
          },
        );
      } else {
        debugPrint('File does not exist: $cleanedPath');
        return defaultErrorWidget;
      }
    } catch (e) {
      debugPrint('Exception loading image: $e');
      return defaultErrorWidget;
    }
  }

  /// Build circular image widget
  static Widget buildCircularImage({
    required String path,
    required double size,
    Widget? errorWidget,
    BoxFit fit = BoxFit.cover,
  }) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: buildImage(
          path: path,
          width: size,
          height: size,
          fit: fit,
          errorWidget: errorWidget ??
              Container(
                width: size,
                height: size,
                color: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: size * 0.6,
                ),
              ),
        ),
      ),
    );
  }

  /// Build rounded image widget
  static Widget buildRoundedImage({
    required String path,
    double? width,
    double? height,
    double borderRadius = 12.0,
    Widget? errorWidget,
    BoxFit fit = BoxFit.cover,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: buildImage(
        path: path,
        width: width,
        height: height,
        fit: fit,
        errorWidget: errorWidget,
      ),
    );
  }

  /// Build image with placeholder loading
  static Widget buildImageWithLoading({
    required String path,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return buildImage(
      path: path,
      width: width,
      height: height,
      fit: fit,
      errorWidget: errorWidget,
      placeholder: Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  /// Get image file from path
  static File? getImageFile(String path) {
    try {
      final cleanedPath = cleanPath(path);
      final file = File(cleanedPath);
      return file.existsSync() ? file : null;
    } catch (e) {
      debugPrint('Error getting image file: $e');
      return null;
    }
  }

  /// Validate image path
  static bool isValidImagePath(String? path) {
    if (path == null || path.isEmpty) {
      return false;
    }

    if (isAssetPath(path)) {
      return true; // Assume asset exists
    }

    if (isNetworkPath(path)) {
      return true; // Assume network URL is valid
    }

    return fileExists(path);
  }
}
