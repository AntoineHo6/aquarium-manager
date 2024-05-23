import 'package:aquarium_bleu/firestore_stuff.dart';
import 'package:aquarium_bleu/models/tank.dart';
import 'package:aquarium_bleu/my_cache_manager.dart';
import 'package:aquarium_bleu/pages/add_tank_page.dart';
import 'package:aquarium_bleu/pages/tank_page.dart';
import 'package:aquarium_bleu/providers/tank_provider.dart';
import 'package:aquarium_bleu/strings.dart';
import 'package:aquarium_bleu/styles/spacing.dart';
import 'package:aquarium_bleu/widgets/msg_alert_dialog.dart';
import 'package:aquarium_bleu/widgets/tanks/tank_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TanksPage extends StatefulWidget {
  const TanksPage({super.key});

  @override
  State<TanksPage> createState() => _TanksPageState();
}

class _TanksPageState extends State<TanksPage> {
  @override
  Widget build(BuildContext context) {
    final tankProvider = Provider.of<TankProvider>(context, listen: false);

    SharedPreferences.getInstance().then((myPrefs) {
      bool isWelcomeMsgSeen = myPrefs.getBool(Strings.isWelcomeMsgSeen) ?? false;

      if (!isWelcomeMsgSeen) {
        Future.delayed(
            Duration.zero,
            () => showDialog(
                  context: context,
                  builder: (BuildContext context) => MsgAlertDialog(
                    title: Text('${AppLocalizations.of(context)!.welcomeToAquariumBleu}!'),
                    content: Text(AppLocalizations.of(context)!.welcomeContent),
                  ),
                ));

        myPrefs.setBool(Strings.isWelcomeMsgSeen, true);
      }
    });

    return Scaffold(
      body: StreamBuilder<List<Tank>>(
        stream: FirestoreStuff.readTanks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.2,
                  flexibleSpace: FlexibleSpaceBar(
                    title: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.yourTanks,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTankPage(),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                    ),
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: const Icon(Icons.sort_rounded),
                    // )
                  ],
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: snapshot.data!.length + 1,
                    (BuildContext context, int index) {
                      // if rendering the last item
                      if (index == snapshot.data!.length) {
                        return Padding(
                          padding: const EdgeInsets.all(Spacing.screenEdgePadding),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddTankPage(),
                              ),
                            ),
                            child: Card(
                              child: SizedBox(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * 0.25,
                                child: Icon(
                                  Icons.add,
                                  size: MediaQuery.of(context).size.width * 0.10,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      Tank tank = snapshot.data!.elementAt(index);
                      tankProvider.tankNames.add(tank.name.toLowerCase());

                      if (tank.imgName != null) {
                        return FutureBuilder(
                          future: MyCacheManager().getCacheImage(
                            '${FirebaseAuth.instance.currentUser!.uid}/${tank.imgName}',
                          ),
                          builder: ((context, snapshot) {
                            if (snapshot.hasData) {
                              Widget image = CachedNetworkImage(
                                imageUrl: snapshot.data!,
                                placeholder: (context, url) =>
                                    const Center(child: CircularProgressIndicator.adaptive()),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                fit: BoxFit.cover,
                              );
                              return Padding(
                                padding: const EdgeInsets.all(
                                  Spacing.screenEdgePadding,
                                ),
                                child: TankCard(
                                  tank: tank,
                                  image: image,
                                  onPressed: () {
                                    tankProvider.tank = tank;
                                    tankProvider.image = image;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const TankPage(),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return const Center(child: CircularProgressIndicator.adaptive());
                            }
                          }),
                        );
                      } else {
                        Widget image = Image.asset(
                          "assets/images/koi_pixel.png",
                          fit: BoxFit.cover,
                        );
                        return Padding(
                          padding: const EdgeInsets.all(
                            Spacing.screenEdgePadding,
                          ),
                          child: TankCard(
                            tank: tank,
                            image: image,
                            onPressed: () {
                              tankProvider.tank = tank;
                              tankProvider.image = image;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TankPage(),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      ),
    );
  }
}
