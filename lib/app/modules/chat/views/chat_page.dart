import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nexachat/app/modules/chat/views/chat_list_view.dart';
import 'package:nexachat/app/modules/profile/views/profil_picture_view.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:nexachat/bottom_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../data/models/message_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/providers/chat_provider.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../calls/views/call_view.dart';
import '../../profile/views/otherprofile_view.dart';
import '../controller/chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/date_separator.dart';
import '../widgets/message_input_bar.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String myId;
  final UserModel otherUser;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.myId,
    required this.otherUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  late final ChatController _chatController;
  var highlightedMessageId = ''.obs;
  MessageModel? replyingTo;

  /// Permet de scroller jusqu’au message auquel on répond
  void _scrollToMessage(MessageModel message) {
    final index = _chatController.messages.indexWhere(
      (m) => m.id == message.id,
    );
    if (index != -1 && _itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      highlightMessage(message.id);
    }
  }

  ///coloration de message
  void highlightMessage(String messageId) {
    highlightedMessageId.value = messageId;

    Future.delayed(const Duration(milliseconds: 600), () {
      highlightedMessageId.value = '';
    });
  }

  ///get my name

  /// Envoi d’un nouveau message
  void _sendMessage(String text) {
    final message = MessageModel(
      id: DateTime.now().toIso8601String(),
      chatId: widget.chatId,
      senderId: widget.myId,
      text: text,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
      replyTo: replyingTo?.id,
    );

    _chatController.sendMessage(message);
    setState(() => replyingTo = null);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_itemScrollController.isAttached) {
        _itemScrollController.scrollTo(
          index: _chatController.messages.length - 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<ChatController>()) {
      _chatController = Get.find<ChatController>();
    } else {
      final repo = ChatRepository(provider: ChatProvider());
      _chatController = Get.put(ChatController(repository: repo));
    }
    _chatController.initChat(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage("assets/images/img_8.png"),
          fit: BoxFit.fill,
          opacity: 1,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.iconNonNeutral,
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () {
              Get.offAll(() => BottomAppBarView());
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: GestureDetector(
            onTap: () => Get.to(
              () => OtherProfileView(
                user: widget.otherUser,
                chatController: _chatController,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                // CircleAvatar(radius: 20.sp, backgroundColor: Colors.white),
                widget.otherUser.profileImageUrl != null &&
                        widget.otherUser.profileImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(360),
                        child: CachedNetworkImage(
                          imageUrl: widget.otherUser.profileImageUrl ?? "",
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person, size: 24),
                          ),
                          errorWidget: (_, __, ___) => CircleAvatar(
                            radius: 20,
                            child: Text(
                              widget.otherUser.name[0].toUpperCase(),
                              style: TextStyle(fontSize: 22.sp),
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 24,
                        child: Text(
                          widget.otherUser.name[0].toUpperCase(),
                          style: TextStyle(fontSize: 22.sp),
                        ),
                      ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.otherUser.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _chatController
                                  .formatStatusDateTime(
                                    widget.otherUser.lastSeen!,
                                  )
                                  .length <
                              12
                          ? Text(
                              widget.otherUser.isOnline
                                  ? loc.online
                                  : _chatController.formatStatusDateTime(
                                      widget.otherUser.lastSeen!,
                                    ),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: Colors.white70),
                            )
                          : Marquee(
                              animationDuration: Duration(milliseconds: 100),
                              child: Text(
                                widget.otherUser.isOnline
                                    ? loc.online
                                    : _chatController.formatStatusDateTime(
                                        widget.otherUser.lastSeen!,
                                      ),
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: Colors.white70),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(
                  () => CallView(user: widget.otherUser, isOutgoing: true),
                );
              },
              icon: const Icon(Icons.video_call_outlined),
            ),
            IconButton(
              onPressed: () {
                Get.to(
                  () => CallView(user: widget.otherUser, isOutgoing: true),
                );
              },
              icon: const Icon(Icons.call_outlined),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),

        ///=== BODY ===
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                final messages = _chatController.messages;

                if (messages.isEmpty) {
                  return const Center(child: Text("Aucun message"));
                }
                return ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  initialScrollIndex: messages.length - 1,
                  shrinkWrap: false,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final prev = index > 0 ? messages[index - 1] : null;
                    final showDateSeparator =
                        prev == null || !isSameDay(prev.sentAt, message.sentAt);

                    final next = index < messages.length - 1
                        ? messages[index + 1]
                        : null;

                    final isGrouped = prev?.senderId == message.senderId;
                    final isNextSameSender = next?.senderId == message.senderId;
                    // final showTime = !isNextSameSender;
                    final showTime = true;

                    final replied = messages
                        .where((m) => m.id == message.replyTo)
                        .cast<MessageModel?>()
                        .firstOrNull;

                    return Column(
                      children: [
                        if (showDateSeparator)
                          DateSeparator(date: message.sentAt),
                        VisibilityDetector(
                          key: Key(message.id),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0.5) {
                              _chatController.markMessageAsSeen(message);
                            }
                          },
                          child: Obx(() {
                            final isHighlighted =
                                highlightedMessageId.value == message.id;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? AppColors.iconNonNeutral.withOpacity(0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ChatBubble(
                                message: message,
                                isMe: (message.senderId == widget.myId),
                                repliedMessage: replied,
                                chatController: _chatController,
                                isGrouped: isGrouped,
                                showTime: showTime,
                                onReplyTap: _scrollToMessage,
                                onSwipeToReply: (msg) {
                                  setState(() => replyingTo = msg);
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),

            ///Barre d'entrée de message
            MessageInputBar(
              replyingTo: replyingTo,
              chatController: _chatController,
              onCancelReply: () => setState(() => replyingTo = null),
              onSendMessage: _sendMessage,
              onAttachFile: () => debugPrint('Pièce jointe ajoutée'),
              onRecordAudio: () => debugPrint('Enregistrement audio démarré'),
            ),
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
