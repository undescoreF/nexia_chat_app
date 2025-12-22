import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/message_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/appcolors.dart';
import '../controller/chat_controller.dart';
import '../controller/file_manager_controller.dart';
import 'attachement_menu.dart';
import 'audio_recorder.dart';

class MessageInputBar extends StatefulWidget {
  final ChatController chatController;
  final Function(String message)? onSendMessage;
  final VoidCallback? onAttachFile;
  final VoidCallback? onRecordAudio;
  final MessageModel? replyingTo;
  final VoidCallback? onCancelReply;

  const MessageInputBar({
    super.key,
    required this.chatController,
    this.onSendMessage,
    this.onAttachFile,
    this.onRecordAudio,
    this.replyingTo,
    this.onCancelReply,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();
  final fileManager = Get.put(FileManagerController());
  final _recorder = AudioRecorder();

  bool _isTyping = false;
  bool showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();

  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  String? _audioFilePath;

  void _onTextChanged() =>
      setState(() => _isTyping = _controller.text.trim().isNotEmpty);

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage?.call(text);
      _controller.clear();
      setState(() => _isTyping = false);
    }
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.start(RecordConfig(), path: path);

      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
        _audioFilePath = null;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordDuration += const Duration(seconds: 1));
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();

    setState(() {
      _isRecording = false;
      _audioFilePath = path;
    });
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _recorder.stop();

    if (_audioFilePath != null) {
      final f = File(_audioFilePath!);
      if (await f.exists()) await f.delete();
    }

    setState(() {
      _isRecording = false;
      _audioFilePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: AppColors.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyingTo != null) _buildReplyBar(context),

            if (_isRecording)
              RecordUI(
                duration: _recordDuration,
                onCancel: _cancelRecording,
                onStop: _stopRecording,
              ),

            if (_audioFilePath != null)
              AudioPreview(
                filePath: _audioFilePath!,
                onCancel: () async {
                  final f = File(_audioFilePath!);
                  if (await f.exists()) await f.delete();
                  setState(() => _audioFilePath = null);
                },
                onSend: () async {
                  await widget.chatController.sendFile(File(_audioFilePath!));
                  setState(() => _audioFilePath = null);
                },
              ),

            if (!_isRecording && _audioFilePath == null)
              Row(
                children: [
                  Expanded(child: _buildTextField(loc)),
                  const SizedBox(width: 6),
                  _buildSendOrRecordButton(),
                ],
              ),

            showEmojiPicker ? SizedBox(height: 2.h) : const SizedBox.shrink(),

            if (showEmojiPicker)
              EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  // Do something when emoji is tapped
                  setState(() {
                    _controller.text += emoji.emoji;
                    _isTyping = true;
                  });
                },
                onBackspacePressed: () {
                  // Backspace-Button tapped logic
                  // Remove this line to also remove the button in the UI
                },
                config: Config(
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: AppColors.background,
                    iconColor: AppColors.iconNonNeutral,
                    iconColorSelected: AppColors.iconNeutral,
                    backspaceColor: AppColors.iconNeutral,
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(
                    backgroundColor: AppColors.iconNonNeutral,
                    buttonColor: Colors.transparent,
                    showBackspaceButton: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.replyingTo!.text ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onCancelReply,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        focusNode: _focusNode,
        onChanged: (_) => _onTextChanged(),
        onTap: () => setState(() => showEmojiPicker = false),
        decoration: InputDecoration(
          hintText: loc.message,
          border: InputBorder.none,
          prefixIcon: IconButton(
            icon: Icon(Icons.emoji_emotions_outlined),
            color: AppColors.iconNonNeutral,
            onPressed: () {
              setState(() {
                showEmojiPicker = !showEmojiPicker;
                if (showEmojiPicker) {
                  _focusNode.unfocus();
                } else {
                  FocusScope.of(context).requestFocus(_focusNode);
                }
              });
            },
          ),
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                //onTap: () => fileManager.pickImageFromCamera(),
                onTap: () async {
                  await fileManager.pickImageFromCamera();
                  final file = fileManager.pickedFile.value;
                  if (file != null) {
                    await widget.chatController.sendFile(file);
                    fileManager.pickedFile.value = null;
                  }
                },
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.iconNeutral,
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (_) => ModernAttachmentMenu(
                      onPhoto: () async {
                        await fileManager.pickImage(context);
                        final file = fileManager.pickedFile.value;
                        if (file != null) {
                          await widget.chatController.sendFile(file);
                          fileManager.pickedFile.value = null;
                        }
                      },
                      onVideo: () async {
                        await fileManager.pickVideo();
                        final file = fileManager.pickedFile.value;
                        if (file != null) {
                          await widget.chatController.sendFile(file);
                          fileManager.pickedFile.value = null;
                        }
                      },
                      onDocument: () async {
                        await fileManager.pickAnyFile();
                        final file = fileManager.pickedFile.value;
                        if (file != null) {
                          await widget.chatController.sendFile(file);
                          fileManager.pickedFile.value = null;
                        }
                      },
                      onAudio: () async {
                        await fileManager.pickAudio();
                        final file = fileManager.pickedFile.value;
                        if (file != null) {
                          await widget.chatController.sendFile(file);
                          fileManager.pickedFile.value = null;
                        }
                      },
                      onLocation: () => print("Location"),
                    ),
                  );
                },
                icon: Icon(
                  Icons.attach_file_outlined,
                  color: AppColors.iconNeutral,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        minLines: 1,
        maxLines: 5,
      ),
    );
  }

  Widget _buildSendOrRecordButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.deepPurpleAccent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          _isRecording
              ? Icons.stop
              : (_isTyping ? Icons.send_rounded : Icons.mic_rounded),
          color: Colors.white,
        ),
        onPressed: () {
          if (_isRecording) {
            _stopRecording();
          } else if (_isTyping) {
            _handleSend();
          } else {
            _startRecording();
          }
        },
      ),
    );
  }
}
