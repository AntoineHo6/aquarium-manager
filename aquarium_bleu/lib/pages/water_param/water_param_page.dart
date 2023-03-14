import 'package:aquarium_bleu/models/parameter.dart';
import 'package:aquarium_bleu/models/tank.dart';
import 'package:aquarium_bleu/pages/water_param/tune_chart_page.dart';
import 'package:aquarium_bleu/pages/water_param/water_param_chart_page.dart';
import 'package:aquarium_bleu/providers/cloud_firestore_provider.dart';
import 'package:aquarium_bleu/strings.dart';
import 'package:aquarium_bleu/widgets/water_param/add_param_val_alert_dialog.dart';
import 'package:aquarium_bleu/widgets/water_param/water_param_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class WaterParamPage extends StatefulWidget {
  final Tank tank;

  const WaterParamPage(this.tank, {super.key});

  @override
  State<WaterParamPage> createState() => _WaterParamPageState();
}

class _WaterParamPageState extends State<WaterParamPage> {
  @override
  Widget build(BuildContext context) {
    final firestoreProvider = Provider.of<CloudFirestoreProvider>(context);

    List<Stream<DocumentSnapshot<Map<String, dynamic>>>> prefsStreams = [];

    prefsStreams.add(firestoreProvider.readParamVisPrefs(widget.tank.docId));
    prefsStreams.add(firestoreProvider.readDateRangePrefs(widget.tank.docId));

    return StreamBuilder(
      stream: CombineLatestStream.list(prefsStreams),
      builder: (context, prefsSnapshots) {
        if (prefsSnapshots.hasData) {
          Map<String, dynamic>? paramvisibility = prefsSnapshots.data![0].data();
          List<String> visibleParams = [];

          prefsSnapshots.data![0].data()!.forEach((param, isVisible) {
            if (isVisible) {
              visibleParams.add(param);
            }
          });

          String dateRangeType = prefsSnapshots.data![1][Strings.type];

          DateTime start = _calculateDateStart(
            dateRangeType,
            (prefsSnapshots.data![1][Strings.customDateStart] as Timestamp),
          );
          DateTime end = _calculateDateEnd(
            dateRangeType,
            (prefsSnapshots.data![1][Strings.customDateEnd] as Timestamp),
          );

          List<Stream<List<Parameter>>> dataStreams = [];
          if (prefsSnapshots.data![1][Strings.type] != Strings.all) {
            for (String param in Strings.params) {
              if (paramvisibility![param]) {
                dataStreams.add(
                  context.watch<CloudFirestoreProvider>().readParametersWithRange(
                        widget.tank.docId,
                        param,
                        start,
                        end,
                      ),
                );
              }
            }
          } else {
            for (String param in Strings.params) {
              if (prefsSnapshots.data![0][param]) {
                dataStreams.add(
                  context.watch<CloudFirestoreProvider>().readParameters(widget.tank.docId, param),
                );
              }
            }
          }

          // add condition if no param is visible. Return a different body with a message

          return StreamBuilder(
            stream: CombineLatestStream.list(dataStreams),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<WaterParamChart> charts = _createWaterParamCharts(snapshot.data!);

                return Scaffold(
                  appBar: AppBar(
                    title: Text(AppLocalizations.of(context).waterParameters),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TuneChartPage(
                                widget.tank.docId,
                                prefsSnapshots.data![1][Strings.type],
                                start,
                                end,
                                paramvisibility,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune_rounded),
                      )
                    ],
                  ),
                  body: ListView(children: charts),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => AddParamValAlertDialog(
                        widget.tank.docId,
                        visibleParams,
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                );
              } else {
                return const CircularProgressIndicator.adaptive();
              }
            },
          );
        } else {
          return const CircularProgressIndicator.adaptive();
        }
      },
    );
  }

  DateTime _calculateDateStart(String type, Timestamp customDateStart) {
    switch (type) {
      case Strings.months1:
        return DateTime.now().subtract(const Duration(days: 31));
      case Strings.months2:
        return DateTime.now().subtract(const Duration(days: 62));
      case Strings.months3:
        return DateTime.now().subtract(const Duration(days: 93));
      case Strings.months6:
        return DateTime.now().subtract(const Duration(days: 186));
      case Strings.months9:
        return DateTime.now().subtract(const Duration(days: 279));
      case Strings.custom:
        return customDateStart.toDate();
      default:
        return DateTime.now();
    }
  }

  DateTime _calculateDateEnd(String type, Timestamp customDateEnd) {
    if (type == Strings.custom) {
      return customDateEnd.toDate();
    }

    return DateTime.now();
  }

  List<WaterParamChart> _createWaterParamCharts(List<List<Parameter>> allParamData) {
    List<WaterParamChart> charts = [];
    for (var i = 0; i < allParamData.length; i++) {
      if (allParamData[i].isNotEmpty) {
        charts.add(
          WaterParamChart(
            param: allParamData[i][0].type,
            dataSource: allParamData[i],
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WaterParamChartPage(
                        widget.tank.docId,
                        allParamData[i][0].type,
                        allParamData[i],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          ),
        );
      }
    }

    return charts;
  }
}
