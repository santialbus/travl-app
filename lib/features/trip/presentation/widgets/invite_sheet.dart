import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';

class InviteSheet extends StatelessWidget {
  const InviteSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr('invite_members'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(context.tr('share_code_with_friends')),
          const SelectableText('ABC-123', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('close'))),
        ],
      ),
    );
  }
}
