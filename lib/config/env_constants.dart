class EnvConstants {
  static late String instagramAccessToken;
  static late String instagramUserId;
  static late String rapidKey;
  static late String youtubeApiKey;
  static late String youtubeChannelId;
  static late String youtubeUploadPlaylistId;

  static void init(Map<String, String> env) {
    instagramAccessToken = env['INSTAGRAM_ACCESS_TOKEN'] ?? '';
    instagramUserId = env['INSTAGRAM_USER_ID'] ?? '';
    rapidKey = env['RAPID_KEY'] ?? '';
    youtubeApiKey = env['YOUTUBE_API_KEY'] ?? '';
    youtubeChannelId = env['YOUTUBE_CHANNEL_ID'] ?? '';
    youtubeUploadPlaylistId = env['YOUTUBE_UPLOAD_PLAYLIST_ID'] ?? '';
  }
}
