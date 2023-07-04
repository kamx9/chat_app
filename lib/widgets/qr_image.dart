import 'package:chat_app/models/chat_group.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRImage extends StatelessWidget {
  const QRImage({super.key, required this.chatGroup});
  final ChatGroup chatGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                'Invite friends!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 8,
              ),
              QrImageView(
                data: chatGroup.groupId,
                size: 200,
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
