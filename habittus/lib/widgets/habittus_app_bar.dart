import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../screens/profile_screen.dart';

class HabittusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;

  const HabittusAppBar({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,

      leadingWidth: showBack ? 96 : null,

      leading: Row(
        children: [
          // BOTÃO MENU (drawer)
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.green),
              onPressed: () {
                Scaffold.of(ctx).openDrawer();
              },
            ),
          ),

          // BOTÃO BACK (opcional)
          if (showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        ],
      ),

      actions: [
        // Avatar do utilizador
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2F5D2F),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userController.userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
