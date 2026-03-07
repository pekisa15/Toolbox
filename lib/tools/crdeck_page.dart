import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:toolbox/core/dialogs.dart';
import 'package:toolbox/core/http_requests.dart';
import 'package:toolbox/core/url.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'package:toolbox/models/crdeck_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolbox/core/shared_preferences.dart';

class CrDeckPage extends StatefulWidget {
  const CrDeckPage({super.key});

  @override
  State<CrDeckPage> createState() => _CrDeckPage();
}

class _CrDeckPage extends State<CrDeckPage> {
  final int maxDeckCards = 8;
  final String apiEndpoint = "https://toolbox.koizeay.com/crdeck/cards";
  final String clashRoyaleDeckBaseUrl =
      "https://link.clashroyale.com/en?clashroyale://copyDeck?deck=";
  final audioPlayer = AudioPlayer();
  bool isLoading = true;
  List<CrDeckCard> allCards = [];
  List<CrDeckCard> filteredSearchCards = [];
  List<CrDeckCard> selectedCards = [];
  List<CrDeckCard> showedDeckCards = [];
  List<CrDeckCard> lockedDeckCards = [];

  @override
  void initState() {
    super.initState();
    initPage().then((_) {
      setState(() {
        if (showedDeckCards.isEmpty) {
          isLoading = false;
        }
      });
    }).catchError((error) {
      if (mounted) {
        setState(() {
          showOkTextDialog(context, t.generic.error,
              t.tools.crdeck.error.error_while_loading_cards_from_server);
          isLoading = false;
        });
      }
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    if (allCards.isNotEmpty) {
      await saveSelectedCards();
    }
    await audioPlayer.stop();
    await audioPlayer.dispose();
  }

  Future<void> initPage() async {
    await loadAllCardsFromServer();
    await loadSelectedCards();
  }

  Future<void> loadAllCardsFromServer() async {
    await httpGet(apiEndpoint, {}).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          allCards =
              (jsonDecode(response.body) as Map<String, dynamic>)["items"]
                  .map<CrDeckCard>((item) => CrDeckCard.fromJson(item))
                  .toList();
        });
        allCards.sort((a, b) => a.name.compareTo(b.name));
        filteredSearchCards = List.from(allCards);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.tools.crdeck.error
                  .failed_to_load_cards_from_server(
                      errorCode: response.statusCode)),
            ),
          );
        }
      }
    });
  }

  Future<void> loadSelectedCards() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCardsIds =
        prefs.getStringList(SHARED_PREFERENCES_TOOL_CRDECK_SELECTEDCARDSIDS);
    if (savedCardsIds == null) {
      selectedCards = List.from(allCards);
    } else {
      final savedCardsIdsInt = savedCardsIds
          .map((id) => int.tryParse(id) ?? -1)
          .where((id) => id != -1)
          .toList();
      selectedCards = savedCardsIdsInt
          .map((cardId) => allCards.firstWhere((card) => card.id == cardId))
          .toList();
    }
  }

  Future<void> saveSelectedCards() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedCardsIds =
        selectedCards.map((card) => card.id.toString()).toList();
    await prefs.setStringList(
        SHARED_PREFERENCES_TOOL_CRDECK_SELECTEDCARDSIDS, selectedCardsIds);
  }

  Future<List<CrDeckCard>?> showImportCardsFromPlayerProfileDialog(
      BuildContext context) async {
    TextEditingController tagController = TextEditingController();
    return showDialog<List<CrDeckCard>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.tools.crdeck.import_cards_from_player_profile),
          content: TextField(
            controller: tagController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: t.tools.crdeck.player_tag,
              hintText: "#ABCD1234",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t.generic.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(t.tools.crdeck.import),
              onPressed: () async {
                String playerTag = tagController.text.trim();
                if (playerTag.isEmpty ||
                    playerTag.length < 7 ||
                    playerTag.length > 13) {
                  Navigator.of(context).pop();
                  showOkTextDialog(context, t.tools.crdeck.error.invalid_tag,
                      t.tools.crdeck.error.please_enter_a_valid_player_tag);
                  return;
                }
                if (!playerTag.startsWith("#")) {
                  playerTag = "#$playerTag";
                }
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text(t.tools.crdeck.importing_cards),
                          ],
                        ),
                      );
                    });
                try {
                  final apiUrl =
                      "$apiEndpoint/${Uri.encodeComponent(playerTag)}";
                  final response = await httpGet(apiUrl, {});
                  if (response.statusCode == 200) {
                    final importedCards = (jsonDecode(response.body)
                            as Map<String, dynamic>)["items"]
                        .map<CrDeckCard>((item) => CrDeckCard.fromJson(item))
                        .toList();
                    if (mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(importedCards);
                    }
                  } else {
                    if (mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      showOkTextDialog(
                          context,
                          t.generic.error,
                          t.tools.crdeck.error
                              .failed_to_import_cards_from_player_profile(
                                  errorCode: response.statusCode));
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    showOkTextDialog(
                        context,
                        t.generic.error,
                        t.tools.crdeck.error
                            .an_error_occurred_while_importing_cards);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void randomizeDeck() {
    var selectedCardsNoLocked =
        selectedCards.where((card) => !lockedDeckCards.contains(card)).toList();
    if (selectedCardsNoLocked.length < maxDeckCards - lockedDeckCards.length) {
      showOkTextDialog(
          context,
          t.tools.crdeck.error.not_enough_cards_selected,
          t.tools.crdeck.error.please_select_at_least_x_more_cards(
              numberOfCards: (maxDeckCards - lockedDeckCards.length)));
      return;
    }
    setState(() {
      final availableCards = selectedCards
          .where((card) => !lockedDeckCards.contains(card))
          .toList();
      availableCards.shuffle();
      showedDeckCards = List.from(lockedDeckCards);
      for (var card in availableCards) {
        if (showedDeckCards.length >= maxDeckCards) break;
        showedDeckCards.add(card);
      }
    });
  }

  void addCardToDeck(CrDeckCard card) {
    if (showedDeckCards.length >= maxDeckCards) {
      showOkTextDialog(
          context,
          t.tools.crdeck.error.deck_is_full,
          t.tools.crdeck.error.you_can_only_add_up_to_x_cards_to_the_deck(
              numberOfCards: maxDeckCards));
      return;
    }
    if (showedDeckCards.contains(card)) {
      showOkTextDialog(context, t.tools.crdeck.error.card_already_in_deck,
          t.tools.crdeck.error.this_card_is_already_in_the_deck);
      return;
    }
    setState(() {
      showedDeckCards.add(card);
    });
    audioPlayer
        .play(
            UrlSource("$apiEndpoint/audio/${card.id}", mimeType: "audio/mpeg"))
        .onError((error, stackTrace) {});
  }

  void removeCardFromDeck(CrDeckCard card) {
    setState(() {
      showedDeckCards.remove(card);
      lockedDeckCards.remove(card);
    });
  }

  void selectOrUnselectCard(CrDeckCard card) {
    setState(() {
      if (selectedCards.contains(card)) {
        selectedCards.remove(card);
      } else {
        selectedCards.add(card);
      }
    });
  }

  Future<void> openDeckInClashRoyale() async {
    if (showedDeckCards.length < maxDeckCards) {
      showOkTextDialog(
          context,
          t.tools.crdeck.error.incomplete_deck,
          t.tools.crdeck.error
              .please_add_x_more_cards_to_the_deck_before_opening_it_in_clash_royale(
                  numberOfCards: maxDeckCards - showedDeckCards.length));
      return;
    }
    String deckCode = showedDeckCards.map((card) => card.id).join(";");
    String url = "$clashRoyaleDeckBaseUrl$deckCode&tt=159000000&l=Royals";
    await launchUrlInBrowser(url);
  }

  Future<void> shareDeck() async {
    if (showedDeckCards.length < maxDeckCards) {
      showOkTextDialog(
          context,
          t.tools.crdeck.error.incomplete_deck,
          t.tools.crdeck.error
              .please_add_x_more_cards_to_the_deck_before_sharing_it(
                  numberOfCards: maxDeckCards - showedDeckCards.length));
      return;
    }
    String deckCode = showedDeckCards.map((card) => card.id).join(";");
    String url = "$clashRoyaleDeckBaseUrl$deckCode&tt=159000000&l=Royals";
    ShareParams shareParams = ShareParams(
      sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      text: t.tools.crdeck.share_deck_text_message(url: url),
    );
    await SharePlus.instance.share(shareParams);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(t.tools.crdeck.title),
            actions: [
              IconButton(
                icon: Icon(Icons.cleaning_services_outlined),
                onPressed: () {
                  setState(() {
                    // Clear unlocked deck cards only
                    showedDeckCards = List.from(lockedDeckCards);
                  });
                },
                tooltip: t.tools.crdeck.clear_unlocked_deck_cards,
              ),
              IconButton(
                icon: Icon(Icons.copyright_outlined),
                onPressed: () {
                  List<TextButton> creditsButtons = [
                    TextButton(
                      onPressed: () {
                        launchUrlInBrowser("https://supercell.com/en/games/clashroyale/");
                        Navigator.of(context).pop();
                      },
                      child: Text(t.tools.crdeck.supercell_website),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(t.generic.ok),
                    ),
                  ];
                  showCustomButtonsTextDialog(
                      context,
                      t.tools.crdeck.about_and_credits,
                      t.tools.crdeck.about_and_credits_description,
                      creditsButtons);
                },
                tooltip: t.tools.crdeck.about_and_credits,
              ),
            ],
          ),
          body: SafeArea(
            child: isLoading
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ))
                : allCards.isEmpty
                    ? Center(
                        child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          t.tools.crdeck.error
                              .please_check_your_internet_connection,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ))
                    : Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: Center(
                                child: showedDeckCards.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          t.tools.crdeck.no_deck,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(4.0),
                                        scrollDirection: Axis.horizontal,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 4.0,
                                          crossAxisSpacing: 4.0,
                                          childAspectRatio: 4 / 3,
                                        ),
                                        itemCount: maxDeckCards,
                                        itemBuilder: (context, index) {
                                          if (index >= showedDeckCards.length) {
                                            return Container();
                                          }
                                          final card = showedDeckCards[index];
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (lockedDeckCards
                                                    .contains(card)) {
                                                  lockedDeckCards.remove(card);
                                                } else {
                                                  lockedDeckCards.add(card);
                                                }
                                              });
                                            },
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: Image.network(
                                                    card.iconUrls.medium,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(Icons
                                                          .image_not_supported_outlined);
                                                    },
                                                  ),
                                                ),
                                                if (lockedDeckCards
                                                    .contains(card))
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    child: Container(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.8),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Icon(
                                                          Icons.lock_outlined,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          randomizeDeck();
                                        });
                                      },
                                      child: Text(
                                          t.tools.crdeck.generate_new_deck),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(Icons.open_in_new_outlined),
                                    onPressed: () {
                                      openDeckInClashRoyale();
                                    },
                                    tooltip: t
                                        .tools.crdeck.open_deck_in_clash_royale,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share_outlined),
                                    onPressed: () {
                                      shareDeck();
                                    },
                                    tooltip: t.tools.crdeck.share_deck,
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 4.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: t.tools.crdeck.search_cards,
                                  prefixIcon: Icon(Icons.search_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    filteredSearchCards = allCards
                                        .where((card) => card.name
                                            .toLowerCase()
                                            .contains(
                                                value.trim().toLowerCase()))
                                        .toList();
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 2.0, right: 2.0, bottom: 2.0, top: 0.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        icon:
                                            Icon(Icons.cloud_download_outlined),
                                        tooltip: t.tools.crdeck
                                            .import_cards_from_player_profile,
                                        onPressed: () async {
                                          final cards =
                                              await showImportCardsFromPlayerProfileDialog(
                                                  context);
                                          if (cards != null) {
                                            setState(() {
                                              selectedCards = allCards
                                                  .where((card) => cards.any(
                                                      (importedCard) =>
                                                          importedCard.id ==
                                                          card.id))
                                                  .toList();
                                            });
                                          }
                                        }),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.deselect_outlined),
                                          onPressed: () {
                                            setState(() {
                                              selectedCards.clear();
                                            });
                                          },
                                          tooltip:
                                              t.tools.crdeck.deselect_all_cards,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.select_all_outlined),
                                          onPressed: () {
                                            setState(() {
                                              selectedCards =
                                                  List.from(allCards);
                                            });
                                          },
                                          tooltip:
                                              t.tools.crdeck.select_all_cards,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredSearchCards.length,
                                itemBuilder: (context, index) {
                                  final card = filteredSearchCards[index];
                                  return Card(
                                    color: selectedCards.contains(card)
                                        ? null
                                        : Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.2),
                                    child: ListTile(
                                        onTap: () {
                                          selectOrUnselectCard(card);
                                        },
                                        leading: Container(
                                          foregroundDecoration:
                                              selectedCards.contains(card)
                                                  ? null
                                                  : BoxDecoration(
                                                      color: Colors.grey,
                                                      backgroundBlendMode:
                                                          BlendMode.saturation,
                                                    ),
                                          width: 48,
                                          height: 48,
                                          child: Image.network(
                                            card.iconUrls.medium,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(Icons
                                                  .image_not_supported_outlined);
                                            },
                                          ),
                                        ),
                                        trailing: GestureDetector(
                                          onTap: () {
                                            if (showedDeckCards
                                                .contains(card)) {
                                              removeCardFromDeck(card);
                                            } else {
                                              addCardToDeck(card);
                                            }
                                          },
                                          child: Icon(
                                            showedDeckCards.contains(card)
                                                ? Icons
                                                    .remove_circle_outline_outlined
                                                : Icons
                                                    .add_circle_outline_outlined,
                                          ),
                                        ),
                                        title: Text(card.name),
                                        subtitle: Text(t.tools.crdeck.x_elixirs(
                                            elixirs: card.elixirCost ?? '?'))),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
          )),
    );
  }
}
