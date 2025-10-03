import 'package:equatable/equatable.dart';

enum MediaType { track, album, playlist, video, radio, podcast }

class MediaItem extends Equatable {
  const MediaItem({
    required this.id,
    required this.title,
    required this.artists,
    required this.artworkUrl,
    required this.type,
    this.duration,
    this.isLive = false,
    this.isLiked = false,
    this.isDownloaded = false,
  });

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] as String,
      title: map['title'] as String,
      artists: List<String>.from(map['artists'] as List<dynamic>),
      artworkUrl: map['artworkUrl'] as String,
      type: MediaType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => MediaType.track,
      ),
      duration: map['duration'] == null
          ? null
          : Duration(milliseconds: map['duration'] as int),
      isLive: map['isLive'] as bool? ?? false,
      isLiked: map['isLiked'] as bool? ?? false,
      isDownloaded: map['isDownloaded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artists': artists,
      'artworkUrl': artworkUrl,
      'type': type.name,
      'duration': duration?.inMilliseconds,
      'isLive': isLive,
      'isLiked': isLiked,
      'isDownloaded': isDownloaded,
    };
  }

  final String id;
  final String title;
  final List<String> artists;
  final String artworkUrl;
  final MediaType type;
  final Duration? duration;
  final bool isLive;
  final bool isLiked;
  final bool isDownloaded;

  MediaItem copyWith({
    String? id,
    String? title,
    List<String>? artists,
    String? artworkUrl,
    MediaType? type,
    Duration? duration,
    bool? isLive,
    bool? isLiked,
    bool? isDownloaded,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      isLive: isLive ?? this.isLive,
      isLiked: isLiked ?? this.isLiked,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, artists, artworkUrl, type, duration, isLive, isLiked, isDownloaded];
}
