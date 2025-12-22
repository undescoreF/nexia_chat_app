import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:nexachat/app/modules/chat/controller/chat_controller.dart';
import 'package:nexachat/app/modules/chat/views/find_contact.dart';
import 'package:nexachat/app/modules/chat/widgets/message_tile.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:nexachat/data/models/user_model.dart';
import 'package:nexachat/data/providers/user_provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/providers/chat_provider.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../auth/controllers/userController.dart';
import '../../calls/controller/call_controllers.dart';
import 'chat_page.dart';
import 'dummy_msg.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  late final ChatController _chatController;
  late final UserController userController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ChatController>()) {
      _chatController = Get.put(
        ChatController(repository: ChatRepository(provider: ChatProvider())),
        permanent: true,
      );
    } else {
      _chatController = Get.find<ChatController>();
    }

    // UserController — permanent
    if (!Get.isRegistered<UserController>()) {
      Get.put(UserRepository(UserProvider()), permanent: true);

      userController = Get.put(
        UserController(Get.find<UserRepository>()),
        permanent: true,
      );
    } else {
      userController = Get.find<UserController>();
    }

    final callController = Get.find<CallControllers>();
    callController.listenForIncomingCalls(
      FirebaseAuth.instance.currentUser!.uid,
    );
  }
  // Initialiser GetX

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        title: Text(
          "Nexia Chat",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          /*IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.iconNonNeutral,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.iconNonNeutral),
            onPressed: () {},
          ),*/
        ],
        /*        bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Divider(color: AppColors.divider,)
        ),*/
      ),

      body: Column(
        children: [
          SearchBar(
            hintText: loc.search,
            leading: Icon(Icons.search, color: AppColors.iconNeutral),
            backgroundColor: WidgetStatePropertyAll(Color(0xffF2F2F7)),
            textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 16.sp)),
            elevation: WidgetStatePropertyAll(0),
            padding: WidgetStatePropertyAll(EdgeInsets.only(left: 5.w)),
            constraints: BoxConstraints(minHeight: 7.h, maxHeight: 8.h),
            onChanged: (value) {
              _chatController.searchQuery.value = value;
            },
          ).paddingOnly(left: 3.w, right: 3.w, top: 2.h),
          SizedBox(height: 2.h),
          Expanded(
            child: Obx(() {
              /*   if (_chatController.isLoadingChats.value) {
                return const Center(child: CircularProgressIndicator());
              }*/

              final chats =
                  (_chatController.filteredChats.isEmpty &&
                      _chatController.searchQuery.isEmpty)
                  ? _chatController.userChats
                  : _chatController.filteredChats;
              if (chats.isEmpty) {
                return const Center(child: Text("Aucun chat"));
              }
              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final myUid = FirebaseAuth.instance.currentUser!.uid;
                  final other = chat.participantsInfo.firstWhere(
                    (p) => p.uid != myUid,
                  );
                  final otherUid = chat.participantsInfo
                      .firstWhere((p) => p.uid != myUid)
                      .uid;
                  if (!userController.users.containsKey(otherUid)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      userController.bindUserStream(otherUid);
                    });
                  }
                  final otherUserRx = userController.users[otherUid];
                  if (otherUserRx == null) {
                    return SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () async {
                      //await userController.loadUserInfo(other.uid);
                      final otherUser = otherUserRx?.value;
                      if (otherUser == null) return;
                      Get.to(
                        () => ChatPage(
                          chatId: chat.id,
                          myId: myUid,
                          otherUser: otherUser!,
                        ),
                      );
                    },
                    child: Obx(() {
                      final otherUser = otherUserRx?.value;
                      if (otherUser == null) {
                        return SizedBox.shrink();
                      }

                      return MessageTile(
                        name: otherUser.name,
                        lastMessage: chat.lastMessagePreview,
                        time: _chatController.formatChatDate(
                          context,
                          chat.lastMessageTime!,
                        ),
                        avatarUrl: otherUser.profileImageUrl ?? "",
                        unreadCount: chat.unreadCount.value,
                        lastMessageStatus: chat.lastMessageStatus,
                        isMe: chat.lastMessageSender == myUid,
                      );
                    }),
                    /* Obx(() {
                      return MessageTile(
                        name: otherUser!.name,
                        lastMessage: chat.lastMessagePreview,
                        time: _chatController.formatChatDate(
                          context,
                          chat.lastMessageTime!,
                        ),
                        avatarUrl: otherUser!.profileImageUrl!,
                        unreadCount: chat.unreadCount.value,
                        lastMessageStatus: chat.lastMessageStatus,
                        isMe: chat.lastMessageSender == myUid,
                      );
                    }),*/
                  );
                },
              );
            }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => FindContactPage());
        },
        shape: CircleBorder(),
        backgroundColor: AppColors.iconNonNeutral,
        child: Icon(Icons.chat, color: AppColors.background),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
