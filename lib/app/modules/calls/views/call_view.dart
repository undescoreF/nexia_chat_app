import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:nexachat/app/modules/calls/controller/call_controllers.dart';
import 'package:nexachat/data/models/user_model.dart';
import 'package:sizer/sizer.dart';

class CallView extends StatefulWidget {
  final UserModel user;
  final bool isOutgoing;
  const CallView({super.key, required this.user, this.isOutgoing = true});

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  late final CallControllers _controller;
  final String myId = FirebaseAuth.instance.currentUser!.uid;
  double _pipX = 0.85;
  double _pipY = 0.7;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CallControllers>();
    ever(_controller.shouldCloseCallView, (shouldClose) {
      if (shouldClose) {
        Get.back();
      }
    });
    if (widget.isOutgoing) {
      _controller.startCall(myId, widget.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (_controller.isInCall.value) {
          if (!_controller.webRTCService_.isRemoteRendererInitialized.value) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return _buildConnectedCallView();
        } else {
          return _buildCallingView();
        }
      }),
      floatingActionButton: Obx(() {
        if (_controller.isInCall.value) {
          return _buildCallControlButtons();
        } else if (widget.isOutgoing) {
          return _buildOutgoingCallButton();
        } else {
          return _buildIncomingCallButtons();
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black87,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
      ),
      centerTitle: true,
      title: Row(
        children: [
          Icon(Icons.lock, color: Colors.white, size: 16.sp),
          SizedBox(width: 3.w),
          Text(
            "Appel chiffré",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
        ],
      ).paddingOnly(left: 2.w),
    );
  }

  Widget _buildCallingView() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 15.h),
        Center(
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.deepPurpleAccent,
            child: (widget.user.profileImageUrl?.isNotEmpty == true)
                ? buildAvatar(widget.user.profileImageUrl!, size: 500)
                : Text(
                    widget.user.name[0].toUpperCase(),
                    style: TextStyle(fontSize: 70, color: Colors.white),
                  ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          widget.user.name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(color: Colors.white),
        ),
        SizedBox(height: 10),
        Obx(
          () => Text(
            _controller.callStatus.value.isEmpty
                ? (widget.isOutgoing ? "Appel en cours…" : "Appel entrant…")
                : _controller.callStatus.value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedCallView() {
    return Stack(
      children: [
        // second user
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _controller.remoteRenderer.srcObject != null
                ? RTCVideoView(
                    _controller.remoteRenderer,
                    mirror: false,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Container(color: Colors.black),
          ),
        ),

        // username
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              widget.user.name,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(color: Colors.white),
            ),
          ),
        ),

        //  PIP
        if (_controller.isLocalRendererInitialized.value)
          Positioned(
            left: _pipX * MediaQuery.of(context).size.width,
            top: _pipY * MediaQuery.of(context).size.height,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: (details) {
                final dx = details.delta.dx / MediaQuery.of(context).size.width;
                final dy =
                    details.delta.dy / MediaQuery.of(context).size.height;

                setState(() {
                  _pipX = (_pipX + dx).clamp(0.02, 0.88);
                  _pipY = (_pipY + dy).clamp(0.05, 0.75);
                });
              },
              onPanEnd: (_) {
                setState(() {
                  _isDragging = false;
                });
              },
              child: Container(
                width: 40.w,
                height: 30.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(_isDragging ? 0.9 : 0.4),
                    width: _isDragging ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(
                    _controller.localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCallControlButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.92,
        height: 85,
        borderRadius: 25,
        blur: 25,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // VOLUME (placeholder)
            circleButton(
              icon: Icons.volume_up,
              isPrimaryRed: false,
              isActive: true,
              onTap: () {},
            ),
            // TOGGLE CAMÉRA
            circleButton(
              icon: _controller.localStream?.getVideoTracks().isNotEmpty == true
                  ? Icons.videocam
                  : Icons.videocam_off,
              isPrimaryRed: false,
              isActive:
                  _controller.localStream?.getVideoTracks().isNotEmpty == true,
              onTap: _toggleCamera,
            ),
            // TOGGLE MICRO
            circleButton(
              icon: _isMicrophoneEnabled() ? Icons.mic : Icons.mic_off,
              isPrimaryRed: !_isMicrophoneEnabled(),
              isActive: _isMicrophoneEnabled(),
              onTap: _toggleMicrophone,
            ),
            // RACCROCHER
            circleButton(
              icon: Icons.call_end,
              isPrimaryRed: true,
              isActive: false,
              onTap: () async {
                widget.isOutgoing
                    ? await _controller.endCall(myId, widget.user.uid)
                    : _controller.rejectCall(myId, widget.user.uid);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingCallButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 60,
        borderRadius: 25,
        blur: 25,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
        ),
        child: circleButton(
          icon: Icons.call_end,
          isPrimaryRed: true,
          isActive: false,
          onTap: () async {
            await _controller.endCall(myId, widget.user.uid);
            Get.back();
          },
        ),
      ),
    );
  }

  Widget _buildIncomingCallButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          circleButton(
            icon: Icons.call_end,
            isPrimaryRed: true,
            isActive: false,
            onTap: () async {
              await _controller.rejectCall(myId, widget.user.uid);
              Get.back();
            },
          ),
          circleButton(
            icon: Icons.call,
            isPrimaryRed: false,
            isActive: true,
            onTap: () async {
              try {
                final offerDoc = await _controller.callRepository_.callProvider_
                    .getOffer(myId, widget.user.uid);
                final data = offerDoc.data() as Map<String, dynamic>;
                if (data['offer'] != null) {
                  final remoteOffer = RTCSessionDescription(
                    data['offer'],
                    'offer',
                  );
                  await _controller.acceptCall(
                    remoteOffer,
                    myId: myId,
                    otherId: widget.user.uid,
                  );
                }
              } catch (e) {
                Get.snackbar('Erreur', 'Impossible d’accepter l’appel');
              }
            },
          ),
        ],
      ),
    );
  }

  //  Toggle micro
  void _toggleMicrophone() {
    final audioTracks = _controller.localStream?.getAudioTracks();
    if (audioTracks != null && audioTracks.isNotEmpty) {
      final track = audioTracks[0];
      track.enabled = !track.enabled;
    }
  }

  bool _isMicrophoneEnabled() {
    final audioTracks = _controller.localStream?.getAudioTracks();
    return audioTracks != null &&
        audioTracks.isNotEmpty &&
        audioTracks[0].enabled;
  }

  //  Toggle caméra
  void _toggleCamera() {
    final videoTracks = _controller.localStream?.getVideoTracks();
    if (videoTracks != null && videoTracks.isNotEmpty) {
      final track = videoTracks[0];
      track.enabled = !track.enabled;
    }
  }

  Widget circleButton({
    required IconData icon,
    required bool isPrimaryRed,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white
              : (isPrimaryRed ? Colors.red : Colors.black),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isPrimaryRed
              ? Colors.white
              : (isActive ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget buildAvatar(String imageUrl, {double size = 500}) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade300,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade300,
          child: const Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }
}
