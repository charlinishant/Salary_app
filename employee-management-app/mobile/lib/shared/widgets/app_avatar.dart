import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.imageUrl, this.radius = 24});
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundImage: imageUrl == null ? null : CachedNetworkImageProvider(imageUrl!),
        child: imageUrl == null ? const Icon(Icons.person) : null,
      );
}
