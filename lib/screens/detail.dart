import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/pic.dart';
import '../providers/favs_provider.dart';
import '../services/api.dart';

class DetailScreen extends StatefulWidget {
  final Pic pic;

  const DetailScreen({super.key, required this.pic});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService api = ApiService();
  bool downloading = false;
  double prog = 0.0;

  Future<void> onDownload() async {
    setState(() {
      downloading = true;
      prog = 0.0;
    });

    try {
      final ok = await api.downloadPic(
        widget.pic.fullUrl,
        onProg: (received, total) {
          if (total > 0) {
            setState(() {
              prog = received / total;
            });
          }
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Image saved to gallery!'
              : 'Permission denied or download failed'),
          backgroundColor: ok ? Colors.green[700] : Colors.red[700],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save image'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          downloading = false;
          prog = 0.0;
        });
      }
    }
  }

  void onShare() {
    Share.share(
      'Check out this photo by ${widget.pic.user} on Pixabay: ${widget.pic.fullUrl}',
      subject: 'Photo by ${widget.pic.user}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavsProvider>();
    final isFav = favProvider.isFav(widget.pic.id);
    final tags = widget.pic.tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => favProvider.toggle(widget.pic),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onShare,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Hero(
                tag: 'pic_${widget.pic.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.pic.fullUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => CachedNetworkImage(
                    imageUrl: widget.pic.url,
                    fit: BoxFit.contain,
                  ),
                  errorWidget: (_, _, _) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.black87, Colors.transparent],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 20),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white24,
                          child: Text(
                            widget.pic.user.isNotEmpty
                                ? widget.pic.user[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pic.user,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Pixabay Creator',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: downloading ? null : onDownload,
                          icon: downloading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download, size: 18),
                          label: Text(downloading
                              ? '${(prog * 100).toInt()}%'
                              : 'Download'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    if (downloading) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: prog > 0 ? prog : null,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                          minHeight: 4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildStat(Icons.thumb_up_outlined, '${widget.pic.likes}', 'Likes'),
                        const SizedBox(width: 20),
                        _buildStat(Icons.download_outlined, '${widget.pic.downloads}', 'Downloads'),
                        const SizedBox(width: 20),
                        _buildStat(Icons.visibility_outlined, '${widget.pic.views}', 'Views'),
                      ],
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String val, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
