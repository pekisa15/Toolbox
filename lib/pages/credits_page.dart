import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toolbox/core/dialogs.dart';
import 'package:toolbox/core/url.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'package:toolbox/widgets/credits_action_card.dart';
import 'package:toolbox/widgets/credits_info_card.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});
  final _appLicense = "Mozilla Public License 2.0";

  void showSwissDialog(BuildContext context) {
    showOkTextDialog(
      context,
      t.credits.made_with_love_in_switzerland,
      t.credits.made_with_love_in_switzerland_description
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(t.credits.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CreditsInfoCard(
              icon: Icons.gavel_outlined,
              title: t.credits.app_license(license: _appLicense),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: t.generic.app_name,
                  applicationLegalese: t.credits.app_license(license: _appLicense),
                  applicationIcon: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Image(
                      image: AssetImage("assets/images/icons/icon_rounded.png"),
                      width: 50,
                      height: 50,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            CreditsInfoCard(
              icon: Icons.palette_outlined,
              title: t.credits.app_icon(author: "Koizeay + Icons8"),
            ),
            const SizedBox(height: 12),
            CreditsInfoCard(
              icon: Icons.image_outlined,
              title: t.credits.tools_icons(author: "Icons8"),
              subtitle: "www.icons8.com",
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrlInBrowser("https://www.icons8.com/"),
            ),
            const SizedBox(height: 12),
            CreditsInfoCard(
              icon: Icons.translate,
              title: t.credits.translations.title,
              subtitle: "${t.credits.translations.english(author: "Koizeay")}"
                  "\n${t.credits.translations.french(author: "Koizeay")}",
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: Image(
                        image: AssetImage("assets/images/specific/credits_koizeay_avatar.png"),
                        width: 64,
                        height: 64,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Koizeay",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => launchUrlInBrowser("https://koizeay.com"),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text(
                          "koizeay.com",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: "Email",
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: "me@koizeay.com"));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.credits.email_copied_to_clipboard)),
                            );
                          },
                          icon: SvgPicture.asset(
                            "assets/images/specific/credits_email.svg",
                            colorFilter: ColorFilter.mode(
                              colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                        IconButton(
                          tooltip: "Instagram",
                          onPressed: () => launchUrlInBrowser("https://instagram.com/koizeay.dev"),
                          icon: SvgPicture.asset(
                            "assets/images/specific/credits_instagram.svg",
                            colorFilter: ColorFilter.mode(
                              colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                        IconButton(
                          tooltip: "Bluesky",
                          onPressed: () => launchUrlInBrowser("https://bsky.app/profile/koizeay.dev"),
                          icon: SvgPicture.asset(
                            "assets/images/specific/credits_bluesky.svg",
                            colorFilter: ColorFilter.mode(
                              colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                        IconButton(
                          tooltip: "Discord",
                          onPressed: () => launchUrlInBrowser("https://jtu.me/discord"),
                          icon: SvgPicture.asset(
                            "assets/images/specific/credits_discord.svg",
                            colorFilter: ColorFilter.mode(
                              colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CreditsActionCard(
              icon: Icons.code,
              title: t.credits.contribute_on_github,
              color: colorScheme.primaryContainer,
              textColor: colorScheme.onPrimaryContainer,
              onTap: () => launchUrlInBrowser("https://github.com/Koizeay/Toolbox"),
            ),
            const SizedBox(height: 12),
            CreditsActionCard(
              icon: Icons.favorite,
              title: t.credits.made_with_love_in_switzerland,
              customContent: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    "assets/images/specific/credits_swiss_flag.png",
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
              onTap: () => showSwissDialog(context),
            ),
            const SizedBox(height: 12),
            CreditsActionCard(
              icon: Icons.apps,
              title: t.credits.more_apps_and_services,
              color: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              onTap: () => launchUrlInBrowser("https://jtu.me/projects"),
            ),
            if (Platform.isAndroid) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  t.credits.ads_disclaimer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
