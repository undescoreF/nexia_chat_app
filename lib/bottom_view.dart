import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/modules/chat/views/chat_list_view.dart';
import 'package:nexachat/app/modules/profile/views/profile_view.dart';
import 'package:nexachat/app/utils/appcolors.dart';

import 'app/modules/calls/views/call_history_view.dart';
import 'app/modules/settings/views/settings_view.dart';
import 'l10n/app_localizations.dart';

class BottomAppBarView extends StatefulWidget {
  const BottomAppBarView({super.key});

  @override
  State<BottomAppBarView> createState() => _BottomAppBarViewState();
}

class _BottomAppBarViewState extends State<BottomAppBarView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ChatListView(),
    CallHistoryView(),
    ProfileView(),
    SettingsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [IndexedStack(index: _selectedIndex, children: _pages)],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // showUnselectedLabels: false,
        selectedItemColor: AppColors.iconNonNeutral,
        unselectedItemColor: AppColors.iconNeutral,
        elevation: 18,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: loc.chats,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            label: loc.calls,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: loc.profile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: loc.settings,
          ),
        ],
      ),
    );
  }
}
