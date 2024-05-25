import 'package:aquarium_bleu/pages/settings/theme_page.dart';
import 'package:aquarium_bleu/providers/settings_provider.dart';
import 'package:aquarium_bleu/providers/tank_provider.dart';
import 'package:aquarium_bleu/styles/spacing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final tankProvider = Provider.of<TankProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    Widget authBtn = FirebaseAuth.instance.currentUser!.isAnonymous
        ? ElevatedButton(
            child: Text(AppLocalizations.of(context)!.signIn),
            onPressed: () {
              Navigator.pushNamed(context, '/sign-in');
            },
          )
        : ElevatedButton(
            child: Text(AppLocalizations.of(context)!.signOut),
            onPressed: () {
              tankProvider.emptyTankNames();
              FirebaseAuth.instance
                  .signOut()
                  .then((value) => FirebaseAuth.instance.signInAnonymously().then(
                        (value) => setState(() {}),
                      ));
            },
          );

    String themeStr;

    if (settingsProvider.themeMode == ThemeMode.dark) {
      themeStr = AppLocalizations.of(context)!.dark;
    } else if (settingsProvider.themeMode == ThemeMode.light) {
      themeStr = AppLocalizations.of(context)!.light;
    } else {
      themeStr = AppLocalizations.of(context)!.system;
    }

    String accEmail = FirebaseAuth.instance.currentUser!.email == null ||
            FirebaseAuth.instance.currentUser!.email!.isEmpty
        ? AppLocalizations.of(context)!.noAccountConnected
        : FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
      appBar: AppBar(
          // title: Text(AppLocalizations.of(context)!.settings),
          ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.screenEdgePadding),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.settings,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                accEmail,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(
              height: Spacing.betweenSections,
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.theme),
              subtitle: Text(themeStr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemePage(),
                  ),
                );
              },
            ),
            const SizedBox(
              height: Spacing.betweenSections,
            ),
            Align(
              alignment: Alignment.center,
              child: authBtn,
            ),
          ],
        ),
      ),
    );
  }
}
