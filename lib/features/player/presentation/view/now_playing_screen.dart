import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:conecta_app/core/localization/l10n.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  static const routeName = 'nowPlaying';

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nowPlayingTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://picsum.photos/seed/nowplaying/500/500',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Silk City Vibes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Nova & Friends',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    return Slider(
                      min: 0,
                      max: duration.inMilliseconds
                          .toDouble()
                          .clamp(1, double.infinity),
                      value: position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble(),
                      onChanged: (value) =>
                          _player.seek(Duration(milliseconds: value.toInt())),
                    );
                  },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 32,
                  onPressed: () => _player.seekToPrevious(),
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton.filled(
                      iconSize: 52,
                      onPressed: () async {
                        if (playing) {
                          await _player.pause();
                        } else {
                          await _player.setUrl(
                              'https://samplelib.com/lib/preview/mp3/sample-12s.mp3');
                          await _player.play();
                        }
                      },
                      icon: Icon(playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                    );
                  },
                ),
                IconButton(
                  iconSize: 32,
                  onPressed: () => _player.seekToNext(),
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
