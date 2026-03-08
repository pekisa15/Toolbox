import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:toolbox/core/dialogs.dart';
import 'package:toolbox/core/time.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'package:vibration/vibration.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});
  @override
  State<TimerPage> createState() => _TimerPage();
}

class _TimerPage extends State<TimerPage> {
  bool isPlayingAlarm = false;
  final audioPlayer = AudioPlayer();
  Timer? timer;
  int pickedMilliseconds = 60000;
  int currentMilliseconds = 60000;
  bool isCounting = false;
  bool isPaused = false;
  bool isFinished = false;

  @override
  Future<void> dispose() async {
    stopTimer();
    super.dispose();
  }

  void showIosAlert() {
    showOkTextDialog(
      context,
      t.generic.warning,
      t.tools.timer.ios_warning_message,
    );
  }

  void startTimer() {
    if (pickedMilliseconds == 0) {
      return;
    }
    if (Platform.isIOS && !isPaused) {
      showIosAlert();
    }
    if (!isCounting) {
      stopAlarm();
      timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
        if (currentMilliseconds > 0) {
          setState(() {
            currentMilliseconds--;
          });
        } else {
          timerFinished();
        }
      });
      setState(() {
        isCounting = true;
        isPaused = false;
        isFinished = false;
      });
    }
  }

  void stopTimer() {
    stopAlarm();
    timer?.cancel();
    timer = null;
    currentMilliseconds = pickedMilliseconds;
    setState(() {
      isCounting = false;
      isFinished = false;
    });
  }

  void pauseTimer() {
    if (isCounting) {
      timer?.cancel();
      setState(() {
        isCounting = false;
        isPaused = true;
      });
    }
  }

  void addTime(int millisecondsToAdd) {
    if (isCounting || isPaused) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tools.timer.please_stop_the_timer_first),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (pickedMilliseconds + millisecondsToAdd >= 0 && pickedMilliseconds + millisecondsToAdd < 3600000) {
      setState(() {
        pickedMilliseconds += millisecondsToAdd;
        currentMilliseconds = pickedMilliseconds;
      });
    }
  }

  void timerFinished() {
    timer?.cancel();
    timer = null;
    setState(() {
      isFinished = true;
    });
    playAlarm();
    startVibration();
  }

  void stopAlarm() {
    audioPlayer.stop();
    isPlayingAlarm = false;
  }

  void playAlarm() {
    audioPlayer.onPlayerComplete.listen((event) {
      if (mounted && isPlayingAlarm) {
        audioPlayer.play(AssetSource("audios/timer_alarm.wav"));
      }
    });
    audioPlayer.play(AssetSource("audios/timer_alarm.wav"));
    isPlayingAlarm = true;
  }

  Future<void> startVibration() async {
    if ((await Vibration.hasVibrator())) {
      while (isPlayingAlarm) {
        Vibration.vibrate();
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.tools.timer.title),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Time Display Card
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
                            Icon(
                              isFinished
                                  ? Icons.alarm_outlined
                                  : Icons.hourglass_empty_outlined,
                              color: isFinished
                                  ? colorScheme.error
                                  : colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isFinished ? "Time's Up!" : "Timer",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isFinished ? colorScheme.error : null,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isFinished
                                ? colorScheme.errorContainer
                                : colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              getFormattedTimeFromMilliseconds(currentMilliseconds),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: "Roboto Mono",
                                fontSize: 64,
                                color: isFinished
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onPrimaryContainer,
                              ),
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Time Adjustment Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_outlined,
                                color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              t.tools.timer.adjust_time,
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
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  addTime(-1000);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("-1s"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  addTime(1000);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("+1s"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  addTime(-60000);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("-1m"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  addTime(60000);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("+1m"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Controls Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.control_camera_outlined,
                                color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              "Controls",
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
                        Row(
                          children: [
                            if (isCounting && !isFinished) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.pause_outlined),
                                  label: Text(t.tools.timer.pause),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    pauseTimer();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: FilledButton.icon(
                                icon: Icon(isCounting
                                    ? Icons.stop_outlined
                                    : Icons.play_arrow_outlined),
                                label: Text(isCounting
                                    ? t.tools.timer.stop
                                    : t.tools.timer.start),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isCounting
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (isCounting) {
                                    stopTimer();
                                    return;
                                  }
                                  startTimer();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
