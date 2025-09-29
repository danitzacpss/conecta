import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:conecta_app/features/home/domain/entities/media_item.dart';

class VerticalMediaCard extends StatelessWidget {
  const VerticalMediaCard({required this.item, super.key});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                  imageUrl: item.artworkUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.artists.join(', '),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
