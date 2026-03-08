String getFormattedTimeFromMilliseconds(int milliseconds) {
  Duration duration = Duration(milliseconds: milliseconds);
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String threeDigits(int n) => n.toString().padLeft(3, "0");
  String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
  String threeDigitsMilliseconds = threeDigits(duration.inMilliseconds.remainder(1000));

  return "$twoDigitsMinutes:$twoDigitsSeconds.$threeDigitsMilliseconds";
}