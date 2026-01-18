import 'package:flutter/material.dart';

class HabittusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HabittusAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,

      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.green),
          onPressed: () {
            Scaffold.of(ctx).openDrawer(); // <-- ISTO abre o menu
          },
        ),
      ),

      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.person_outline, color: Colors.green),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
