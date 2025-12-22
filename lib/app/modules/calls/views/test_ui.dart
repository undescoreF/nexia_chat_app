import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../controller/local_controll.dart';

class LocalTestScreen extends GetView<LocalCallController> {
  const LocalTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Local Test'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // CONFIGURATION IP (utilise controller persistent)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: c.serverIpController,
                        decoration: const InputDecoration(
                          labelText: 'IP du Serveur',
                          hintText: '192.168.1.100',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => c.serverIp = v,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // STATUT
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(c.callState.value),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(c.callState.value),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getStatusText(c.callState.value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (c.currentRoomId != null)
                      Text(
                        c.currentRoomId!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // VIDÉOS (Remote grande + Local vignette)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Remote video (observe uniquement remoteStream pour éviter rebuilds excessifs)
                    Obx(() {
                      final remote = c.remoteStream.value;
                      if (remote != null) {
                        return RTCVideoView(
                          c.remoteRenderer_,
                          mirror: false,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'Aucune connexion distante',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    }),

                    // Local video vignette (coin bas droit)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black12,
                        ),
                        child: Obx(() {
                          final local = c.localStream.value;
                          if (local != null) {
                            return RTCVideoView(
                              c.localRenderer_,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            );
                          } else {
                            return const Center(
                              child: Icon(
                                Icons.videocam_off,
                                color: Colors.grey,
                              ),
                            );
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // CONTROLS
            Obx(() {
              final isInCall =
                  c.callState.value == CallState.connected ||
                  c.callState.value == CallState.waiting;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: c.roomIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID de Salle',
                            hintText: 'salle-123',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text('Démarrer Appel'),
                          onPressed: isInCall
                              ? null
                              : () {
                                  final roomId = c.roomIdController.text.isEmpty
                                      ? 'salle-${DateTime.now().millisecondsSinceEpoch}'
                                      : c.roomIdController.text.trim();
                                  c.startCall(roomId);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call_received),
                          label: const Text('Rejoindre'),
                          onPressed: isInCall
                              ? null
                              : () {
                                  final room = c.roomIdController.text.trim();
                                  if (room.isEmpty) {
                                    Get.snackbar(
                                      'Erreur',
                                      'Veuillez entrer un ID de salle',
                                    );
                                    return;
                                  }
                                  c.joinCall(room);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // In-call buttons
                  if (isInCall)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: IconButton(
                            icon: const Icon(Icons.mic, color: Colors.white),
                            onPressed: () {
                              // TODO: mute/unmute
                            },
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                            ),
                            onPressed: c.endCall,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: toggle camera
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    final c = controller;
    Get.dialog(
      AlertDialog(
        title: const Text('Configuration'),
        content: TextField(
          controller: c.serverIpController,
          decoration: const InputDecoration(
            labelText: 'IP du Serveur',
            hintText: '192.168.1.100',
          ),
          onChanged: (v) => c.serverIp = v,
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Fermer'))],
      ),
    );
  }

  // Helpers UI status
  Color _getStatusColor(CallState state) {
    switch (state) {
      case CallState.idle:
        return Colors.grey;
      case CallState.connecting:
        return Colors.orange;
      case CallState.waiting:
        return Colors.blue;
      case CallState.connected:
        return Colors.green;
      case CallState.error:
        return Colors.red;
      case CallState.ended:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(CallState state) {
    switch (state) {
      case CallState.idle:
        return Icons.call_end;
      case CallState.connecting:
        return Icons.connect_without_contact;
      case CallState.waiting:
        return Icons.hourglass_empty;
      case CallState.connected:
        return Icons.call;
      case CallState.error:
        return Icons.error;
      case CallState.ended:
        return Icons.call_end;
    }
  }

  String _getStatusText(CallState state) {
    switch (state) {
      case CallState.idle:
        return 'Prêt à appeler';
      case CallState.connecting:
        return 'Connexion en cours...';
      case CallState.waiting:
        return 'En attente de réponse...';
      case CallState.connected:
        return 'Appel en cours';
      case CallState.error:
        return 'Erreur de connexion';
      case CallState.ended:
        return 'Appel terminé';
    }
  }
}
