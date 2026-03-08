import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toolbox/gen/strings.g.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});
  @override
  State<MetronomePage> createState() => _MetronomePage();
}

class _MetronomePage extends State<MetronomePage> {
  bool isLoading = false;
  bool isPlaying = false;
  final player = AudioPlayer();
  Timer? timer;
  int beatIndex = 0;

  int _currentBpm = 120;
  int _currentBeatsPerMeasure = 4;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    stopMetronome(isDispose: true);
    super.dispose();
  }

  Future<void> startMetronome() async {
    int currentBpm = _currentBpm;
    if (timer != null) {
      await stopMetronome();
    }
    timer = Timer.periodic(
        Duration(milliseconds: (60000 / _currentBpm).round()),
        (timer) async {
          if (currentBpm != _currentBpm) {
            await stopMetronome();
            await startMetronome();
            return;
          }
          if (beatIndex == 0) {
            player.play(AssetSource('audios/metronome_click0.wav'));
          } else {
            player.play(AssetSource('audios/metronome_click.wav'));
          }
          beatIndex = (beatIndex + 1) % _currentBeatsPerMeasure;
        });
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> stopMetronome({isDispose = false}) async {
    timer?.cancel();
    timer = null;
    beatIndex = 0;
    if (!isDispose) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(t.tools.metronome.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // BPM Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.speed_outlined,
                              color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            t.tools.metronome.bpm,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentBpm.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontFamily: "Roboto Mono",
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      NumberPicker(
                        value: _currentBpm,
                        minValue: 25,
                        maxValue: 200,
                        axis: Axis.horizontal,
                        onChanged: (value) =>
                            setState(() => _currentBpm = value),
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                        selectedTextStyle:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Beats per Measure Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.music_note_outlined,
                              color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            t.tools.metronome.beats_per_measure,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentBeatsPerMeasure.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontFamily: "Roboto Mono",
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      NumberPicker(
                        value: _currentBeatsPerMeasure,
                        minValue: 1,
                        maxValue: 12,
                        axis: Axis.horizontal,
                        onChanged: (value) =>
                            setState(() => _currentBeatsPerMeasure = value),
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                        selectedTextStyle:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Control Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (isLoading) {
                      return;
                    }
                    isLoading = true;
                    if (isPlaying) {
                      stopMetronome().then((value) => isLoading = false);
                      return;
                    }
                    startMetronome().then((value) => isLoading = false);
                  },
                  icon: Icon(isPlaying
                      ? Icons.stop_outlined
                      : Icons.play_arrow_outlined),
                  label: Text(isPlaying
                      ? t.tools.metronome.stop
                      : t.tools.metronome.start),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        isPlaying ? colorScheme.error : colorScheme.primary,
                  ),
                ),
              ),
              if (isPlaying) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: colorScheme.tertiaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.graphic_eq_outlined,
                            color: colorScheme.onTertiaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          "Playing...",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
