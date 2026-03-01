import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolbox/core/shared_preferences.dart';
import 'package:toolbox/models/home_folder.dart';
import 'package:toolbox/tools/areacalculator_page.dart';
import 'package:toolbox/tools/baseconverter_page.dart';
import 'package:toolbox/tools/bitwisecalculator_page.dart';
import 'package:toolbox/tools/characterscopy_page.dart';
import 'package:toolbox/tools/clock_page.dart';
import 'package:toolbox/tools/commons_page.dart';
import 'package:toolbox/tools/compass_page.dart';
import 'package:toolbox/tools/counter_page.dart';
import 'package:toolbox/tools/crdeck_page.dart';
import 'package:toolbox/tools/fileencryption_page.dart';
import 'package:toolbox/tools/flipcoins_page.dart';
import 'package:toolbox/tools/gameoflife_page.dart';
import 'package:toolbox/tools/httprequest_page.dart';
import 'package:toolbox/tools/mathtex_page.dart';
import 'package:toolbox/tools/mcserverping_page.dart';
import 'package:toolbox/tools/megaphone_page.dart';
import 'package:toolbox/tools/metronome_page.dart';
import 'package:toolbox/tools/morsecode_page.dart';
import 'package:toolbox/tools/musicsearch_page.dart';
import 'package:toolbox/tools/networkinfo_page.dart';
import 'package:toolbox/tools/nationalanthems_page.dart';
import 'package:toolbox/tools/nearbypublictransportstops_page.dart';
import 'package:toolbox/tools/nslookup_page.dart';
import 'package:toolbox/tools/osm_page.dart';
import 'package:toolbox/tools/passwordgenerator_page.dart';
import 'package:toolbox/tools/pastebin_page.dart';
import 'package:toolbox/tools/percentagecalculator_page.dart';
import 'package:toolbox/tools/ping_page.dart';
import 'package:toolbox/tools/portscanner_page.dart';
import 'package:toolbox/tools/qrcreator_page.dart';
import 'package:toolbox/tools/qrreader_page.dart';
import 'package:toolbox/tools/randomcolor_page.dart';
import 'package:toolbox/tools/randomnumber_page.dart';
import 'package:toolbox/tools/romannumeral_page.dart';
import 'package:toolbox/tools/roulette_page.dart';
import 'package:toolbox/tools/sshclient_page.dart';
import 'package:toolbox/tools/soundmeter_page.dart';
import 'package:toolbox/tools/speedometer_page.dart';
import 'package:toolbox/tools/stopwatch_page.dart';
import 'package:toolbox/tools/musicanalyser_page.dart';
import 'package:toolbox/tools/textcounter_page.dart';
import 'package:toolbox/tools/textdifferences_page.dart';
import 'package:toolbox/tools/texttospeech_page.dart';
import 'package:toolbox/tools/timer_page.dart';
import 'package:toolbox/tools/timestampconverter_page.dart';
import 'package:toolbox/tools/urlshortener_page.dart';
import 'package:toolbox/tools/uuidgenerator_page.dart';
import 'package:toolbox/tools/whiteboard_page.dart';
import 'package:toolbox/tools/whoisdomain_page.dart';
import 'package:toolbox/tools/youtubethumbnail_page.dart';

import 'models/home_tool.dart';
import 'package:toolbox/gen/strings.g.dart';

class Hierarchy {
  static final Map<String, HomeTool> toolMap = {
    "areacalculator": HomeTool(t.tools.areacalculator.title, "assets/images/tools/areacalculator.png", const AreaCalculatorPage()),
    "baseconverter": HomeTool(t.tools.baseconverter.title, "assets/images/tools/baseconverter.png", const BaseConverterPage()),
    "bitwisecalculator": HomeTool(t.tools.bitwisecalculator.title, "assets/images/tools/bitwisecalculator.png", const BitwiseCalculatorPage()),
    "characterscopy": HomeTool(t.tools.characterscopy.title, "assets/images/tools/characterscopy.png", const CharactersCopyPage()),
    "clock": HomeTool(t.tools.clock.title, "assets/images/tools/clock.png", const ClockPage()),
    "commons": HomeTool("Commons", "assets/images/tools/commons.png", const CommonsPage()),
    "compass": HomeTool(t.tools.compass.title, "assets/images/tools/compass.png", const CompassPage()),
    "counter": HomeTool(t.tools.counter.title, "assets/images/tools/counter.png", const CounterPage()),
    "crdeck": HomeTool(t.tools.crdeck.title, "assets/images/tools/crdeck.png", const CrDeckPage()),
    "fileencryption": HomeTool(t.tools.fileencryption.title, "assets/images/tools/fileencryption.png", const FileEncryptionPage()),
    "flipcoins": HomeTool(t.tools.flipcoins.title, "assets/images/tools/flipcoins.png", const FlipCoinsPage()),
    "gameoflife": HomeTool(t.tools.gameoflife.title, "assets/images/tools/gameoflife.png", const GameOfLifePage()),
    "httprequest": HomeTool(t.tools.httprequest.title, "assets/images/tools/httprequest.png", const HttpRequestPage()),
    "mathtex": HomeTool(t.tools.mathtex.title, "assets/images/tools/mathtex.png", const MathTexPage()),
    "mcserverping": HomeTool(t.tools.mc_server_ping.title, "assets/images/tools/mcserverping.png", const McServerPingPage()),
    "megaphone": HomeTool(t.tools.megaphone.title, "assets/images/tools/megaphone.png", const MegaphonePage()),
    "metronome": HomeTool(t.tools.metronome.title, "assets/images/tools/metronome.png", const MetronomePage()),
    "morsecode": HomeTool(t.tools.morsecode.title, "assets/images/tools/morsecode.png", const MorseCodePage()),
    "musicanalyser": HomeTool(t.tools.musicanalyser.title, "assets/images/tools/musicanalyser.png", const MusicAnalyserPage()),
    "musicsearch": HomeTool(t.tools.musicsearch.title, "assets/images/tools/musicsearch.png", const MusicSearchPage()),
    "nationalanthems": HomeTool(t.tools.nationalanthems.title, "assets/images/tools/nationalanthems.png", const NationalAnthemsPage()),
    "nearbypublictransportstops": HomeTool(t.tools.nearbypublictransportstops.title, "assets/images/tools/nearbypublictransportstops.png", const NearbyPublicTransportStopsPage()),
    "networkinfo": HomeTool(t.tools.networkinfo.title, "assets/images/tools/networkinfo.png", const NetworkInfoPage()),
    "nslookup": HomeTool(t.tools.nslookup.title, "assets/images/tools/nslookup.png", const NslookupPage()),
    "osm": HomeTool(t.tools.osm.title, "assets/images/tools/osm.png", const OsmPage()),
    "passwordgenerator": HomeTool(t.tools.passwordgenerator.title, "assets/images/tools/passwordgenerator.png", const PasswordGeneratorPage()),
    "pastebin": HomeTool(t.tools.pastebin.title, "assets/images/tools/pastebin.png", const PastebinPage()),
    "percentagecalculator": HomeTool(t.tools.percentagecalculator.title, "assets/images/tools/percentagecalculator.png", const PercentageCalculatorPage()),
    "ping": HomeTool(t.tools.ping.title, "assets/images/tools/ping.png", const PingPage()),
    "portscanner": HomeTool(t.tools.portscanner.title, "assets/images/tools/portscanner.png", const PortScanner()),
    "qrcreator": HomeTool(t.tools.qrcreator.title, "assets/images/tools/qrcreator.png", const QrCreatorPage()),
    "qrreader": HomeTool(t.tools.qrreader.title, "assets/images/tools/qrreader.png", const QrReaderPage()),
    "randomcolor": HomeTool(t.tools.randomcolor.title, "assets/images/tools/randomcolor.png", const RandomColorPage()),
    "randomnumber": HomeTool(t.tools.randomnumber.title, "assets/images/tools/randomnumber.png", const RandomNumberPage()),
    "romannumeral": HomeTool(t.tools.romannumeral.title, "assets/images/tools/romannumeral.png", const RomanNumeralPage()),
    "roulette": HomeTool(t.tools.roulette.title, "assets/images/tools/roulette.png", const RoulettePage()),
    "soundmeter": HomeTool(t.tools.soundmeter.title, "assets/images/tools/soundmeter.png", const SoundMeterPage()),
    "speedometer": HomeTool(t.tools.speedometer.title, "assets/images/tools/speedometer.png", const SpeedometerPage()),
    "sshclient": HomeTool(t.tools.sshclient.title, "assets/images/tools/sshclient.png", const SshClientPage()),
    "stopwatch": HomeTool(t.tools.stopwatch.title, "assets/images/tools/stopwatch.png", const StopwatchPage()),
    "textcounter": HomeTool(t.tools.textcounter.title, "assets/images/tools/textcounter.png", const TextCounterPage()),
    "textdifferences": HomeTool(t.tools.textdifferences.title, "assets/images/tools/textdifferences.png", const TextDifferencesPage()),
    "texttospeech": HomeTool(t.tools.texttospeech.title, "assets/images/tools/texttospeech.png", const TextToSpeechPage()),
    "timer": HomeTool(t.tools.timer.title, "assets/images/tools/timer.png", const TimerPage()),
    "timestampconverter": HomeTool(t.tools.timestampconverter.title, "assets/images/tools/timestampconverter.png", const TimestampConverterPage()),
    "urlshortener": HomeTool(t.tools.urlshortener.title, "assets/images/tools/urlshortener.png", const UrlShortenerPage()),
    "uuidgenerator": HomeTool(t.tools.uuidgenerator.title, "assets/images/tools/uuidgenerator.png", const UuidGeneratorPage()),
    "whiteboard": HomeTool(t.tools.whiteboard.title, "assets/images/tools/whiteboard.png", const WhiteBoardPage()),
    "whoisdomain": HomeTool(t.tools.whoisdomain.title, "assets/images/tools/whoisdomain.png", const WhoisDomainPage()),
    "youtubethumbnail": HomeTool(t.tools.youtubethumbnail.title, "assets/images/tools/youtubethumbnail.png", const YouTubeThumbnailPage())
  };

  static final List<dynamic> hierarchy = [
    HomeFolder(t.categories.audio, "assets/images/folders/folder_audio.png", [
      toolMap["metronome"],
      toolMap["morsecode"],
      toolMap["musicanalyser"],
      toolMap["musicsearch"],
      toolMap["nationalanthems"],
      toolMap["soundmeter"],
      toolMap["texttospeech"],
    ]),
    HomeFolder(t.categories.calculations, "assets/images/folders/folder_calculations.png", [
      toolMap["areacalculator"],
      toolMap["baseconverter"],
      toolMap["bitwisecalculator"],
      toolMap["mathtex"],
      toolMap["percentagecalculator"],
      toolMap["romannumeral"],
      toolMap["textcounter"],
    ]),
    HomeFolder(t.categories.games, "assets/images/folders/folder_games.png", [
      toolMap["crdeck"],
      toolMap["gameoflife"],
      toolMap["mcserverping"],
    ]),
    HomeFolder(t.categories.geography, "assets/images/folders/folder_geography.png", [
      toolMap["compass"],
      toolMap["osm"],
      toolMap["nearbypublictransportstops"],
      toolMap["nationalanthems"],
      toolMap["speedometer"],
    ]),
    HomeFolder(t.categories.miscellaneous, "assets/images/folders/folder_miscellaneous.png", [
      toolMap["characterscopy"],
      toolMap["counter"],
      toolMap["fileencryption"],
      toolMap["qrcreator"],
      toolMap["qrreader"],
      toolMap["textdifferences"],
      toolMap["whiteboard"],
    ]),
    HomeFolder(t.categories.network, "assets/images/folders/folder_network.png", [
      toolMap["httprequest"],
      toolMap["mcserverping"],
      toolMap["networkinfo"],
      toolMap["nslookup"],
      toolMap["ping"],
      toolMap["portscanner"],
      toolMap["sshclient"],
      toolMap["whoisdomain"],
    ]),
    HomeFolder(t.categories.random, "assets/images/folders/folder_random.png", [
      toolMap["flipcoins"],
      toolMap["passwordgenerator"],
      toolMap["randomcolor"],
      toolMap["randomnumber"],
      toolMap["roulette"],
      toolMap["uuidgenerator"],
    ]),
    HomeFolder(t.categories.time, "assets/images/folders/folder_time.png", [
      toolMap["clock"],
      toolMap["stopwatch"],
      toolMap["timer"],
      toolMap["timestampconverter"],
    ]),
    HomeFolder(t.categories.web, "assets/images/folders/folder_web.png", [
      toolMap["commons"],
      toolMap["pastebin"],
      toolMap["httprequest"],
      toolMap["urlshortener"],
      toolMap["youtubethumbnail"],
    ]),
  ];

  static List<HomeTool> getFlatHierarchy() {
    List<HomeTool> uniqueItems = [];
    Set<String> uniqueNames = {};

    List<dynamic> flatten(dynamic item) {
      if (item is HomeFolder) {
        return item.content.expand(flatten).toList();
      } else {
        return [item];
      }
    }

    List<dynamic> flat = hierarchy.expand(flatten).toList();

    for (var item in flat) {
      if (item is HomeTool && !uniqueNames.contains(item.name)) {
        uniqueItems.add(item);
        uniqueNames.add(item.name);
      }
    }
    return uniqueItems;
  }

  static String findToolIdByInstance(HomeTool tool) {
    return Hierarchy.toolMap.entries
        .firstWhere((entry) => entry.value == tool)
        .key;
  }

  static Future<List<String>> getFavoriteTools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(SHARED_PREFERENCES_CORE_HOMEPAGE_FAVORITES) ?? [];
  }

  static Future<void> setFavoriteTools(List<String> favoriteTools) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(SHARED_PREFERENCES_CORE_HOMEPAGE_FAVORITES, favoriteTools);
  }

  static Future<void> addFavoriteTool(String toolId) async {
    List<String> favoriteTools = await getFavoriteTools();
    if (!favoriteTools.contains(toolId)) {
      favoriteTools.add(toolId);
      await setFavoriteTools(favoriteTools);
    }
  }

  static Future<void> removeFavoriteTool(String toolId) async {
    List<String> favoriteTools = await getFavoriteTools();
    if (favoriteTools.contains(toolId)) {
      favoriteTools.remove(toolId);
      await setFavoriteTools(favoriteTools);
    }
  }
}
