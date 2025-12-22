import 'package:flutter/material.dart';

class ModernAttachmentMenu extends StatelessWidget {
  final VoidCallback? onPhoto;
  final VoidCallback? onVideo;
  final VoidCallback? onDocument;
  final VoidCallback? onAudio;
  final VoidCallback? onLocation;

  const ModernAttachmentMenu({
    super.key,
    this.onPhoto,
    this.onVideo,
    this.onDocument,
    this.onAudio,
    this.onLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(
                  icon: Icons.image,
                  label: "Gallerie",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    onPhoto?.call();
                  },
                ),
                _item(
                  icon: Icons.videocam_rounded,
                  label: "Vidéo",
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    onVideo?.call();
                  },
                ),
                _item(
                  icon: Icons.insert_drive_file_rounded,
                  label: "Document",
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.pop(context);
                    onDocument?.call();
                  },
                ),
                _item(
                  icon: Icons.headphones,
                  label: "Audio",
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    onAudio?.call();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
