import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  late Function() onSkipToNext;
  late Function() onSkipToPrevious;

  MyAudioHandler() {
    _initializeAudioSession();
    _listenToPlayerState();
  }

  void setSkipCallbacks({required Function() skipToNext, required Function() skipToPrevious}) {
    onSkipToNext = skipToNext;
    onSkipToPrevious = skipToPrevious;
  }

  Future<void> _initializeAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _listenToPlayerState() {
    _player.playbackEventStream.listen(_broadcastState, onError: (error) {});

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        stop();
      }
    }, onError: (error) {});
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {}
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      
      mediaItem.add(null);
      
      playbackState.add(PlaybackState(
        controls: [],
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
      
      await super.stop();
    } catch (e) {}
  }

  @override
  Future<void> skipToNext() async {
    onSkipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    onSkipToPrevious();
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {}
  }

  Future<void> setUrl(String url, String title, String artist, {String? imageUrl}) async {
    try {
      final mediaItem = MediaItem(
        id: url,
        title: title,
        artist: artist,
        artUri: imageUrl != null ? Uri.parse(imageUrl) : null,
      );

      this.mediaItem.add(mediaItem);
      await _player.setUrl(url);
    } catch (e) {
      rethrow;
    }
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
        androidCompactActionIndices: const [0, 1, 2],
        processingState:
            const {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  bool get isPlaying => _player.playing;
  bool get isBuffering => _player.processingState == ProcessingState.buffering;

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}
