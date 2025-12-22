import 'package:flutter/material.dart';

class MessageVideoWidget extends StatelessWidget {
  final String url;
  final String? thumbnailUrl;

  const MessageVideoWidget({super.key, required this.url, this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Thumbnail
        thumbnailUrl != null
            ? Image.network(
                thumbnailUrl!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              )
            : Container(
                height: 200,
                width: 200,
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),

        // Play button
        const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
      ],
    );
  }
}
