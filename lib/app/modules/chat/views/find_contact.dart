import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/modules/chat/views/chat_page.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/user_model.dart';
import '../../../../data/providers/chat_provider.dart';
import '../../../../data/providers/user_provider.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/appcolors.dart';
import '../controller/chat_controller.dart';

class FindContactPage extends StatefulWidget {
  const FindContactPage({super.key});

  @override
  State<FindContactPage> createState() => _FindContactPageState();
}

class _FindContactPageState extends State<FindContactPage> {
  final TextEditingController _searchController = TextEditingController();
  late final UserProvider _userProvider;
  late final UserRepository _userRepo;
  String _query = "";
  late final ChatController _chatController;
  late final ChatRepository _chatRepository;

  @override
  void initState() {
    super.initState();
    _chatRepository = ChatRepository(provider: ChatProvider());
    if (Get.isRegistered<ChatController>()) {
      _chatController = Get.find<ChatController>();
    } else {
      _chatController = Get.put(ChatController(repository: _chatRepository));
    }
    _userProvider = UserProvider();
    _userRepo = UserRepository(_userProvider);

    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Rechercher un contact'),
        backgroundColor: AppColors.iconNonNeutral,
        title: Text(
          loc.search_contact,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.background),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.name_or_email,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Text(
                      loc.type_to_search_user,
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  )
                : StreamBuilder<List<UserModel>>(
                    stream: _userRepo.searchUsersStream(_query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.iconNonNeutral,
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(loc.no_user_found));
                      }

                      final users = snapshot.data!;

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              child: user.profileImageUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.email),
                            onTap: () async {
                              final currentUid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final chatId = await _chatController.createChat(
                                currentUid,
                                user.uid,
                              );
                              Get.to(
                                () => ChatPage(
                                  chatId: chatId,
                                  myId: currentUid,
                                  otherUser: user,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
