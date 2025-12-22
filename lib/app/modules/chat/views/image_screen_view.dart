import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sizer/sizer.dart';

class ImageScreenView extends StatelessWidget {
  final String imageUrl;
  final File? localFile;

  const ImageScreenView({super.key, required this.imageUrl, this.localFile});

  ImageScreenView.fromMessage({super.key})
    : imageUrl = Get.arguments['imageUrl'],
      localFile = Get.arguments['localFile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadImage,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareImage,
          ),
        ],
      ),
      body: Center(child: _buildImageContent()),
    );
  }

  Widget _buildImageContent() {
    if (localFile != null) {
      return PhotoView(
        imageProvider: FileImage(localFile!),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      );
    } else if (imageUrl.isNotEmpty) {
      return PhotoView(
        imageProvider: CachedNetworkImageProvider(imageUrl),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained * 0.5,
        maxScale: PhotoViewComputedScale.covered * 2,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white, size: 50.sp),
              SizedBox(height: 2.h),
              Text(
                'Erreur de chargement',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      );
    } else {
      // Aucune image disponible
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.white, size: 50.sp),
            SizedBox(height: 2.h),
            Text(
              'Image non disponible',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        ),
      );
    }
  }

  void _downloadImage() {
    ///a implementer
    Get.snackbar(
      'Téléchargement',
      'Fonctionnalité à implémenter',
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
  }

  void _shareImage() {
    ///à implementer
    Get.snackbar(
      'Partage',
      'Fonctionnalité à implémenter',
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
    );
  }
}
