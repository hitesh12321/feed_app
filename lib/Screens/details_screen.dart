import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String thumbUrl; // cache se turant dikhe
  final String mobileUrl; // fade-in hoga
  final String rawUrl; // sirf download pe fetch ho

  const DetailScreen({
    required this.id,
    required this.thumbUrl,
    required this.mobileUrl,
    required this.rawUrl,
    super.key,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _mobileLoaded = false; // mobile image load hua ya nahi
  bool _isDownloading = false; // download button loader

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: widget.id,
                    child: Image.network(
                      widget.thumbUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),

                  Image.network(
                    widget.mobileUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        // — fade-in karo
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _mobileLoaded = true);
                          }
                        });
                        return AnimatedOpacity(
                          opacity: _mobileLoaded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: child,
                        );
                      }

                      return Positioned(
                        bottom: 10,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isDownloading ? null : _downloadHighRes,
                icon: _isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isDownloading ? 'Downloading...' : 'Download High-Res',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadHighRes() async {
    setState(() => _isDownloading = true);

    try {
      // to take permission for storage or photos based on platform and android version
      PermissionStatus status;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos
            .request(); // iOS ke liye photos permission
      }

      if (!status.isGranted) {
        _showSnackBar('⚠️ Storage permission is required to download.');
        return;
      }

      // 2. Raw image download karo
      final dio = Dio();
      final response = await dio.get(
        widget.rawUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // 3. Gallery mein save karo
      await Gal.putImageBytes(response.data, name: 'post_${widget.id}');
      _showSnackBar('✅ Image saved to gallery!');
    } catch (e) {
      _showSnackBar('❌ Download failed. Please try again.');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
