import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/powersync/powersync_config.dart';
import '../../auth/services/session_service.dart';

/// Muestra la fotografía de una observación resolviéndola en este orden:
/// 1) archivo local en el dispositivo (ruta guardada al capturarla);
/// 2) caché local de descargas previas (uploads bajados del servidor);
/// 3) descarga desde el backend (`GET /attachments/<id>`) con el token Kospia,
///    guardándola en la caché para próximas aperturas.
///
/// Así, aunque se reinstale la app y se pierdan los archivos locales
/// originales, la foto se recupera desde el storage del servidor.
class PhotoThumbnail extends StatefulWidget {
  const PhotoThumbnail({
    super.key,
    required this.photoId,
    required this.localPath,
    this.width = 64,
    this.height = 64,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  final String photoId;
  final String localPath;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  @override
  State<PhotoThumbnail> createState() => _PhotoThumbnailState();
}

class _PhotoThumbnailState extends State<PhotoThumbnail> {
  // Caché en memoria del proceso: evita re-descargar la misma foto por sesión.
  static final Map<String, Uint8List> _memoryCache = {};

  File? _localFile;
  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(PhotoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoId != widget.photoId ||
        oldWidget.localPath != widget.localPath) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    setState(() {
      _loading = true;
      _failed = false;
      _localFile = null;
      _bytes = null;
    });

    // 1) Archivo local original (captura en este dispositivo).
    if (widget.localPath.isNotEmpty) {
      final original = File(widget.localPath);
      if (await original.exists()) {
        if (!mounted) return;
        setState(() {
          _localFile = original;
          _loading = false;
        });
        return;
      }
    }

    // 2) Caché en memoria.
    final cached = _memoryCache[widget.photoId];
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _bytes = cached;
        _loading = false;
      });
      return;
    }

    // 3) Caché en disco de descargas previas.
    final cacheFile = await _cacheFile();
    if (await cacheFile.exists()) {
      final data = await cacheFile.readAsBytes();
      _memoryCache[widget.photoId] = data;
      if (!mounted) return;
      setState(() {
        _bytes = data;
        _loading = false;
      });
      return;
    }

    // 4) Descarga desde el backend y cacheo.
    await _downloadFromServer(cacheFile);
  }

  Future<File> _cacheFile() async {
    final dir = await getApplicationCacheDirectory();
    final folder = Directory('${dir.path}/attachments');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File('${folder.path}/${widget.photoId}.img');
  }

  Future<void> _downloadFromServer(File cacheFile) async {
    try {
      final session = await context.read<SessionService>().loadSession();
      if (session == null) {
        if (!mounted) return;
        setState(() {
          _failed = true;
          _loading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${PowerSyncConfig.backendUrl}/attachments/${widget.photoId}',
        ),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.bodyBytes;
        _memoryCache[widget.photoId] = data;
        try {
          await cacheFile.writeAsBytes(data, flush: true);
        } catch (_) {
          // Si falla la escritura en caché, igual mostramos los bytes.
        }
        if (!mounted) return;
        setState(() {
          _bytes = data;
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return Container(
        color: AppColors.surfaceLilac,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_localFile != null) {
      return Image.file(
        _localFile!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.surfaceLilac,
      child: Icon(
        _failed
            ? Icons.broken_image_rounded
            : Icons.image_not_supported_rounded,
        size: 20,
        color: AppColors.textLight,
      ),
    );
  }
}

/// Visor a pantalla completa de una fotografía resuelta por id (local o
/// descargada del servidor), con zoom. Reutiliza [PhotoThumbnail] para la
/// resolución local-primero/servidor-después.
class FullPhotoByIdViewer extends StatelessWidget {
  const FullPhotoByIdViewer({
    super.key,
    required this.photoId,
    required this.localPath,
  });

  final String photoId;
  final String localPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: PhotoThumbnail(
            photoId: photoId,
            localPath: localPath,
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
