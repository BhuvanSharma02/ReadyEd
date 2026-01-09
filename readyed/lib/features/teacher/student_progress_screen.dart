
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/user_model.dart';

class StudentProgressScreen extends StatelessWidget {
  final UserModel student;

  const StudentProgressScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student.name}\'s Progress'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _printReport(context),
        icon: const Icon(Icons.print),
        label: const Text('Print Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildChartCard(context),
            const SizedBox(height: 24),
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAchievementsList(context),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                student.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.class_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Class: ${student.studentClass ?? "N/A"}'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('School: ${student.schoolCode ?? "N/A"}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text('Rank: ${student.getRank()}'),
                    backgroundColor: Colors.amber.shade100,
                    avatar: const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    // Mock data based on score for visual representation
    // Ideally we'd store drill-specific scores
    final double preparednessScore = (student.totalScore % 100).toDouble() + 50; 
    
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                      String text;
                      switch (value.toInt()) {
                        case 0: text = 'Drills'; break;
                        case 1: text = 'Quizzes'; break;
                        case 2: text = 'Safety'; break;
                        default: text = '';
                      }
                      return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: style));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(toY: student.completedDrills.length * 20.0, color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(4))
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: student.totalScore > 100 ? 90 : student.totalScore.toDouble(), color: Colors.green, width: 20, borderRadius: BorderRadius.circular(4))
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(toY: preparednessScore > 100 ? 95 : preparednessScore, color: Colors.orange, width: 20, borderRadius: BorderRadius.circular(4))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context) {
    if (student.achievements.isEmpty) {
      return const Center(child: Text('No achievements yet.'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: student.achievements.length,
      itemBuilder: (context, index) {
        final achievementName = student.achievements[index]
            .replaceAll('_', ' ')
            .split(' ')
            .map((s) => s[0].toUpperCase() + s.substring(1))
            .join(' ');
            
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.medal, color: Colors.amber, size: 32),
              const SizedBox(height: 8),
              Text(
                achievementName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _printReport(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('ReadyEd Student Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Student Name: ${student.name}', style: const pw.TextStyle(fontSize: 18)),
                      pw.Text('Class: ${student.studentClass ?? "N/A"}'),
                      pw.Text('School Code: ${student.schoolCode ?? "N/A"}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                      pw.Text('Total Score: ${student.totalScore}'),
                      pw.Text('Rank: ${student.getRank()}'),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text('Performance Overview', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Paragraph(text: '${student.name} has completed ${student.completedDrills.length} survival scenarios and has earned ${student.achievements.length} achievement badges.'),
              
              pw.SizedBox(height: 20),
              
              // Visual Chart Section for PDF
              pw.Container(
                height: 150,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildPdfBar('Drills', student.completedDrills.length * 20.0, PdfColors.blue),
                    _buildPdfBar('Quizzes', student.totalScore > 100 ? 90.0 : student.totalScore.toDouble(), PdfColors.green),
                    _buildPdfBar('Safety', ((student.totalScore % 100) + 50).toDouble(), PdfColors.orange),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Text('Achievements Unlocked:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: student.achievements.map((ach) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(ach.replaceAll('_', ' ')),
                  );
                }).toList(),
              ),
              
              pw.Spacer(),
              pw.Divider(),
              pw.Center(child: pw.Text('Generated by ReadyEd App - Disaster Preparedness Platform')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildPdfBar(String label, double value, PdfColor color) {
    final double height = (value / 100 * 100).clamp(0.0, 100.0);
    
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text('${value.toInt()}%', style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Container(
          width: 30,
          height: height,
          color: color,
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}
