import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AppUsageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<PieData> subjectData = _getChartData();
    int totalHours = subjectData.fold(0, (sum, data) => sum + data.duration);

    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Vantage Statistics',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Usage Hours',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total Hours: $totalHours hours',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildBarGraph(),
            SizedBox(height: 20),
            _buildSubjectList(subjectData),
          ],
        ),
      ),
    );
  }

  Widget _buildBarGraph() {
    return Container(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        tooltipBehavior: TooltipBehavior(enable: true), // Enable tooltip
        zoomPanBehavior: ZoomPanBehavior(
          enableSelectionZooming: true,
          selectionRectBorderColor: Colors.black,
          enablePanning: false,
          enableDoubleTapZooming: false,
        ),
        series: <BarSeries>[
          BarSeries<PieData, String>(
            dataSource: _getChartData(),
            xValueMapper: (PieData data, _) => data.subject,
            yValueMapper: (PieData data, _) => data.duration,
            color: Colors.pinkAccent, // Bar color
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(List<PieData> subjectData) {
    subjectData.sort((a, b) => a.duration.compareTo(b.duration));

    return Expanded(
      child: ListView.builder(
        itemCount: subjectData.length,
        itemBuilder: (context, index) {
          PieData data = subjectData[index];
          return ListTile(
            title: Text(data.subject),
            subtitle: Text('${data.duration} hours'),
            trailing: Icon(Icons.access_time),
          );
        },
      ),
    );
  }

  List<PieData> _getChartData() {
    return [
      PieData('Day 1', 1, Colors.blue),
      PieData('Day 2', 3, Colors.green),
      PieData('Day 3', 5, Colors.orange),
      PieData('Day 4', 2, Colors.red),
      PieData('Day 5', 4, Colors.red),
    ];
  }
}

class PieData {
  final String subject;
  final int duration;
  final Color color;

  PieData(this.subject, this.duration, this.color);
}

void main() {
  runApp(MaterialApp(
    home: AppUsageScreen(),
  ));
}
