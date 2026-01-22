import 'package:flutter/material.dart';
import '../screens/register_screen.dart';

class HabittusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;

  const HabittusAppBar({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
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
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.green),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
