import 'package:aquarium_bleu/enums/water_param_type.dart';
import 'package:aquarium_bleu/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WaterParamChart extends StatefulWidget {
  final WaterParamType param;
  final List<dynamic> dataSource;
  final List<Widget> actions;
  final List<DateTime> plotBandDates;

  const WaterParamChart({
    required this.param,
    required this.dataSource,
    this.actions = const [],
    this.plotBandDates = const [],
    super.key,
  });

  @override
  State<WaterParamChart> createState() => _WaterParamChartState();
}

class _WaterParamChartState extends State<WaterParamChart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  StringUtil.paramTypeToString(context, widget.param),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: widget.actions,
                ),
              ),
            ],
          ),
        ),
        SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            plotBands: widget.plotBandDates
                .map(
                  (dateTime) => PlotBand(
                    start: dateTime,
                    end: dateTime,
                    shouldRenderAboveSeries: true,
                    borderWidth: 1.5,
                    borderColor: Colors.red,
                  ),
                )
                .toList(),
          ),
          series: <ChartSeries>[
            LineSeries(
              color: ColorScheme.fromSwatch().primary,
              animationDuration: 800,
              dataSource: widget.dataSource,
              xValueMapper: (dataPoint, _) => dataPoint.date,
              yValueMapper: (dataPoint, _) => dataPoint.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              markerSettings: const MarkerSettings(isVisible: true),
            )
          ],
        ),
      ],
    );
  }
}
