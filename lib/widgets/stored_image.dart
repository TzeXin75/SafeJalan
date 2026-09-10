import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider<Object>? storedImageProvider(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  if (path.startsWith('http')) return NetworkImage(path);
  final file = File(path);
  return file.existsSync() ? FileImage(file) : null;
}

class StoredImage extends StatelessWidget {
  const StoredImage({
    super.key,
    required this.path,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final provider = storedImageProvider(path);
    if (provider == null) return fallback;
    return Image(
      image: provider,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class ZoomableStoredImage extends StatelessWidget {
  const ZoomableStoredImage({
    super.key,
    required this.path,
    required this.fallback,
    this.height = 220,
    this.borderRadius = 18,
  });

  final String? path;
  final Widget fallback;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final provider = storedImageProvider(path);
    if (provider == null) {
      return SizedBox(height: height, width: double.infinity, child: fallback);
    }
    return GestureDetector(
      onTap: () => _showFullImage(context, provider),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Image(
                image: provider,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xB3000000),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.zoom_in, color: Colors.white, size: 21),
          ),
        ],
      ),
    );
  }

  Future<void> _showFullImage(
    BuildContext context,
    ImageProvider<Object> provider,
  ) => showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .92),
    builder: (dialogContext) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: .8,
              maxScale: 6,
              child: Center(
                child: Image(image: provider, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: IconButton.filled(
                tooltip: 'Close image',
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
