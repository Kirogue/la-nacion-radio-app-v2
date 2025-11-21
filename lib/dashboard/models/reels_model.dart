/// Modelo que representa un Reel de Instagram
/// Incluye:
/// - id
/// - mediaUrl
/// - thumbnail
/// - caption
/// - timestamp
/// - permalink
///
class Reel {
  final String id;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? caption;
  final DateTime timestamp;
  final String permalink;
  final String? username;
  final String? profilePicture;

  Reel({
    required this.id,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.caption,
    required this.timestamp,
    required this.permalink,
    this.username,
    this.profilePicture,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      id: json['id'],
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      caption: json['caption'],
      timestamp: DateTime.parse(json['timestamp']),
      permalink: json['permalink'],
      username: json['owner']?['username'],
      profilePicture: json['owner']?['profile_picture_url'],
    );
  }
}
