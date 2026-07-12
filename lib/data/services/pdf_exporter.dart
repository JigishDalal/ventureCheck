import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/validation_report.dart';

class PdfExporter {
  static Future<Uint8List> generatePdf(ValidationReport report) async {
    final pdf = pw.Document();

    // Color definitions
    final primaryColor = PdfColor.fromHex('#4F46E5'); // Indigo
    final primaryColorO5 = PdfColor.fromHex('#0D4F46E5'); // 5% Opacity Indigo
    final primaryColorO2 = PdfColor.fromHex('#334F46E5'); // 20% Opacity Indigo
    final secondaryColor = PdfColor.fromHex('#7C3AED'); // Purple
    final textDark = PdfColor.fromHex('#1E293B'); // Slate 800
    final textMuted = PdfColor.fromHex('#64748B'); // Slate 500
    final borderLight = PdfColor.fromHex('#E2E8F0'); // Slate 200

    // SWOT Colors
    final strengthBg = PdfColor.fromHex('#ECFDF5');
    final strengthBorder = PdfColor.fromHex('#10B981');
    final weaknessBg = PdfColor.fromHex('#FFFBEB');
    final weaknessBorder = PdfColor.fromHex('#F59E0B');
    final opportunityBg = PdfColor.fromHex('#F0F9FF');
    final opportunityBorder = PdfColor.fromHex('#0EA5E9');
    final threatBg = PdfColor.fromHex('#FFF5F5');
    final threatBorder = PdfColor.fromHex('#EF4444');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
          italic: pw.Font.helveticaOblique(),
        ),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(bottom: 8),
          margin: const pw.EdgeInsets.only(bottom: 20),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: borderLight, width: 1)),
          ),
          child: pw.Text(
            'Projectthink • AI Startup Validator',
            style: pw.TextStyle(color: textMuted, fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 8),
          margin: const pw.EdgeInsets.only(top: 20),
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: borderLight, width: 1)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated via Projectthink',
                style: pw.TextStyle(color: textMuted, fontSize: 8),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(color: textMuted, fontSize: 8),
              ),
            ],
          ),
        ),
        build: (context) => [
          // Title Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      report.businessName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Startup Validation Report • ${report.category}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SCORE',
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '${report.scores.overallScore}',
                      style: pw.TextStyle(fontSize: 18, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // Metadata Row
          pw.Row(
            children: [
              pw.Text('Priority: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: textDark, fontSize: 9)),
              pw.Text('${report.priority} Priority', style: pw.TextStyle(color: primaryColor, fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 20),
              pw.Text('Market View: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: textDark, fontSize: 9)),
              pw.Text(report.marketView, style: pw.TextStyle(color: textDark, fontSize: 9)),
              pw.SizedBox(width: 20),
              pw.Text('Date: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: textDark, fontSize: 9)),
              pw.Text(report.timestamp.toLocal().toString().split(' ')[0], style: pw.TextStyle(color: textDark, fontSize: 9)),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Divider(color: borderLight, height: 1),
          pw.SizedBox(height: 20),

          // 1. Executive Summary
          pw.Text('1. Executive Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: textDark)),
          pw.SizedBox(height: 8),
          pw.Text(report.summary, style: pw.TextStyle(fontSize: 10, color: textDark, height: 1.4)),
          pw.SizedBox(height: 12),
          pw.Text('Original Startup Concept:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textMuted)),
          pw.SizedBox(height: 4),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: borderLight),
            ),
            child: pw.Text(
              report.ideaText,
              style: pw.TextStyle(fontSize: 9.5, color: textDark, fontStyle: pw.FontStyle.italic),
            ),
          ),

          pw.SizedBox(height: 20),

          // 2. Alignment Matrix
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Core Problem Addressed', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                    pw.SizedBox(height: 4),
                    pw.Text(report.coreProblem, style: pw.TextStyle(fontSize: 9, color: textMuted, height: 1.3)),
                  ],
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Proposed Solution', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                    pw.SizedBox(height: 4),
                    pw.Text(report.proposedSolution, style: pw.TextStyle(fontSize: 9, color: textMuted, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // 3. Validation Metrics
          pw.Text('2. Validation Metrics', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textDark)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: borderLight, width: 0.5),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Score (0-100)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Verdict Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                ],
              ),
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Innovation Potential', style: const pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${report.scores.innovation}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Measures unique features and market disruption potential.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
              ]),
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Market Opportunity', style: const pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${report.scores.marketOpportunity}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(report.marketOpportunity.marketSize, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
              ]),
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Technical Feasibility', style: const pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${report.scores.feasibility}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Overall ease of product implementation (Higher is easier).', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
              ]),
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Business Potential', style: const pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${report.scores.businessPotential}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Scalability and long term value creation analysis.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
              ]),
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Revenue Potential', style: const pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${report.scores.revenuePotential}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Monetization viability and financial prospects.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
              ]),
            ],
          ),

          pw.SizedBox(height: 24),
          pw.NewPage(),

          // 4. SWOT Analysis
          pw.Text('3. SWOT Analysis', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textDark)),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildPdfSwotBlock('Strengths', report.swot.strengths, strengthBg, strengthBorder, textDark),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: _buildPdfSwotBlock('Weaknesses', report.swot.weaknesses, weaknessBg, weaknessBorder, textDark),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildPdfSwotBlock('Opportunities', report.swot.opportunities, opportunityBg, opportunityBorder, textDark),
              ),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: _buildPdfSwotBlock('Threats', report.swot.threats, threatBg, threatBorder, textDark),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // 5. Competitor Audit
          pw.Text('4. Competitor Audit', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textDark)),
          pw.SizedBox(height: 10),
          if (report.competitors.isEmpty)
            pw.Text('No direct competitors identified.', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: textMuted))
          else
            ...report.competitors.map((comp) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderLight, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(comp.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark)),
                        if (comp.launchYear.isNotEmpty)
                          pw.Text('Est: ${comp.launchYear}', style: pw.TextStyle(fontSize: 8, color: textMuted)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(comp.description, style: pw.TextStyle(fontSize: 9, color: textMuted, height: 1.3)),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text('Pricing: ${comp.pricing.isNotEmpty ? comp.pricing : 'N/A'}', style: pw.TextStyle(fontSize: 8, color: textDark)),
                        ),
                        pw.Expanded(
                          child: pw.Text('CEO: ${comp.ceo.isNotEmpty ? comp.ceo : comp.founderName.isNotEmpty ? comp.founderName : 'N/A'}', style: pw.TextStyle(fontSize: 8, color: textDark)),
                        ),
                        pw.Expanded(
                          child: pw.Text('HQ: ${comp.headquarters.isNotEmpty ? comp.headquarters : 'N/A'}', style: pw.TextStyle(fontSize: 8, color: textDark)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          pw.SizedBox(height: 24),
          pw.NewPage(),

          // 6. Strategic Recommendations & Verdict
          pw.Text('5. Strategic AI Recommendations', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textDark)),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: primaryColorO5,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: primaryColorO2, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('VALIDATION VERDICT: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
                    pw.Text(
                      report.recommendations.verdict.toUpperCase(),
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  report.recommendations.reasoning,
                  style: pw.TextStyle(fontSize: 9.5, color: textDark, height: 1.4),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildPdfBulletBlock('Suggested Improvements', report.recommendations.suggestedImprovements, textDark),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildPdfBulletBlock('Monetization Options', report.recommendations.monetizationStrategies, textDark),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildPdfBulletBlock('Benchmarks & Missing Features', report.recommendations.missingFeatures, textDark),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildPdfBulletBlock('Risks to Monitor', report.recommendations.risksToConsider, textDark),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Implementation Roadmap
          pw.Text('Product Implementation Roadmap', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: textDark)),
          pw.SizedBox(height: 8),
          ...List.generate(report.recommendations.roadmapSteps.length, (index) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 14,
                    height: 14,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Text('${index + 1}', style: pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      report.recommendations.roadmapSteps[index],
                      style: pw.TextStyle(fontSize: 9, color: textDark, height: 1.3),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (report.mvpDevPrompt.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.NewPage(),
            pw.Text('6. MVP Coding Blueprint Prompt', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textDark)),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: borderLight, width: 0.5),
              ),
              child: pw.Text(
                report.mvpDevPrompt,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  font: pw.Font.courier(),
                  color: textDark,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfSwotBlock(
    String title,
    List<String> items,
    PdfColor bgColor,
    PdfColor borderColor,
    PdfColor textDark,
  ) {
    return pw.Container(
      height: 110,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: borderColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: borderColor),
          ),
          pw.SizedBox(height: 4),
          pw.Expanded(
            child: pw.ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: pw.TextStyle(color: borderColor, fontSize: 8)),
                    pw.Expanded(
                      child: pw.Text(
                        items[i],
                        style: pw.TextStyle(fontSize: 7.5, color: textDark, height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfBulletBlock(String title, List<String> items, PdfColor textDark) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
        pw.SizedBox(height: 4),
        ...items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                pw.Expanded(
                  child: pw.Text(item, style: pw.TextStyle(fontSize: 8, color: textDark, height: 1.2)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
