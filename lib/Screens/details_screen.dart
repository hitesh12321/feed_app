import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String thumbUrl;    // cache se turant dikhe
  final String mobileUrl;   // fade-in hoga
  final String rawUrl;      // sirf download pe fetch ho

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
  bool _mobileLoaded = false;      // mobile image load hua ya nahi
  bool _isDownloading = false;     // download button loader

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
          // ── Image Section ──
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [

                  // ── Layer 1: Thumbnail (turant cache se) ──
                  Hero(
                    tag: widget.id,
                    child: Image.network(
                      widget.thumbUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),

                  // ── Layer 2: Mobile Image fade-in ──
                  Image.network(
                    widget.mobileUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        // Load ho gaya — fade-in karo
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
                      // Load ho raha hai — thumbnail ke upar progress dikho
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

          // ── Download Button ──
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

  // ── Download Function ──
  Future<void> _downloadHighRes() async {
    setState(() => _isDownloading = true);

    try {
      // 1. Permission lo
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showSnackBar('❌ Storage permission required');
        return;
      }

      // 2. Raw image download karo
      final dio = Dio();
      final response = await dio.get(
        widget.rawUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // 3. Gallery mein save karo
      final result = await ImageGallerySaver.saveImage(
        response.data,
        quality: 100,
        name: 'post_${widget.id}',
      );

      if (result['isSuccess'] == true) {
        _showSnackBar('✅ Image saved to gallery!');
      } else {
        _showSnackBar('❌ Download failed');
      }
    } catch (e) {
      _showSnackBar('❌ Download failed: $e');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}