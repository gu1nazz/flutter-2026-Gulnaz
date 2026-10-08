import 'package:flutter/material.dart';

import 'contacts.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        // Without Expanded: A RenderFlex overflowed by 78 pixels on the right.
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(child: Text(contact.initial)),
                if (contact.unread > 0)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.error,
                        border: Border.all(color: scheme.surface, width: 2),
                      ),
                      child: Text(
                        '${contact.unread}',
                        style: text.labelSmall?.copyWith(color: scheme.onError),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: text.titleMedium),
                  Text(contact.email, style: text.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
