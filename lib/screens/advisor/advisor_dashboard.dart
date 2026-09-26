import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class AdvisorDashboard extends StatelessWidget {
  const AdvisorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          GlassCard(
            backgroundColor: AppTheme.primaryViolet.withValues(alpha: 0.1),
            borderColor: AppTheme.primaryViolet.withValues(alpha: 0.4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryViolet.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: AppTheme.violetLight, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Faculty & Academic Advisor Control Tower',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Empowers university administrators to monitor cohort elective demand, triage at-risk students before finals, and eliminate repetitive advising inquiries across 500+ students.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Institutional Impact Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 950 ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: constraints.maxWidth > 950 ? 1.5 : 2.2,
                children: [
                  _buildImpactCard(
                    title: 'Repetitive Inquiries Deflected',
                    value: '78.4%',
                    subtext: 'Auto-resolved via Edge Concierge',
                    icon: Icons.check_circle_rounded,
                    accentColor: AppTheme.emeraldGreen,
                  ),
                  _buildImpactCard(
                    title: 'Timetable Clashes Prevented',
                    value: '100%',
                    subtext: 'Prior to official registrar lock',
                    icon: Icons.schedule_rounded,
                    accentColor: AppTheme.neonCyan,
                  ),
                  _buildImpactCard(
                    title: 'Advisor Hours Saved / Term',
                    value: '420 Hrs',
                    subtext: 'Across 500+ student cohort',
                    icon: Icons.trending_up_rounded,
                    accentColor: AppTheme.violetLight,
                  ),
                  _buildImpactCard(
                    title: 'Students Triaged Early',
                    value: '18 Students',
                    subtext: 'Proactive intervention dispatched',
                    icon: Icons.warning_amber_rounded,
                    accentColor: AppTheme.amberWarning,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Elective Demand Heatmap & Section Capacity Forecaster
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: AppTheme.neonCyan, size: 20),
                        SizedBox(width: 8),
                        Text('Term 2 & 3 Elective Demand Forecast (500+ Student Cohort)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Live Telemetry Simulation', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Demand Rows
                _buildDemandBar(
                  code: 'PMT650',
                  name: 'Product Strategy & Discovery',
                  enrolled: 145,
                  capacity: 100,
                  status: 'OVERSUBSCRIBED (145%) — Open Section B',
                  isWarning: true,
                ),
                _buildDemandBar(
                  code: 'AID710',
                  name: 'Machine Learning for Business',
                  enrolled: 98,
                  capacity: 100,
                  status: 'OPTIMAL (98%)',
                  isWarning: false,
                ),
                _buildDemandBar(
                  code: 'FIN702',
                  name: 'Corporate Valuation & M&A',
                  enrolled: 112,
                  capacity: 100,
                  status: 'OVERSUBSCRIBED (112%) — Priority to Finance Majors',
                  isWarning: true,
                ),
                _buildDemandBar(
                  code: 'STR710',
                  name: 'Management Consulting Problem Solving',
                  enrolled: 92,
                  capacity: 100,
                  status: 'OPTIMAL (92%)',
                  isWarning: false,
                ),
                _buildDemandBar(
                  code: 'OPS650',
                  name: 'Supply Chain Analytics & Global Logistics',
                  enrolled: 42,
                  capacity: 100,
                  status: 'UNDER CAPACITY (42%) — Recommend cross-listing',
                  isWarning: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cohort At-Risk Student Triage Table
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppTheme.amberWarning, size: 20),
                    SizedBox(width: 8),
                    Text('Automated Academic Early Warning & Triage List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 16),

                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(1.8),
                  },
                  children: [
                    // Header
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFF161E33)),
                      children: [
                        _buildTableHeader('STUDENT NAME'),
                        _buildTableHeader('PROGRAM'),
                        _buildTableHeader('MIDTERM GPA'),
                        _buildTableHeader('FLAGGED RISK'),
                        _buildTableHeader('ACTION'),
                      ],
                    ),
                    _buildStudentRow(
                      context,
                      name: 'Vikram Joshi',
                      program: 'MBA Tech 2025',
                      gpa: '2.84',
                      risk: 'Failing Regression in AID601',
                      isCritical: true,
                    ),
                    _buildStudentRow(
                      context,
                      name: 'Sneha Patel',
                      program: 'MBA Finance 2025',
                      gpa: '3.12',
                      risk: 'Heavy 5-course credit overload',
                      isCritical: false,
                    ),
                    _buildStudentRow(
                      context,
                      name: 'Aditya Rao',
                      program: 'MS AI & Analytics',
                      gpa: '3.05',
                      risk: 'Missing prerequisite for AID730',
                      isCritical: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildImpactCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: accentColor.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accentColor)),
          const SizedBox(height: 4),
          Text(subtext, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  static Widget _buildDemandBar({
    required String code,
    required String name,
    required int enrolled,
    required int capacity,
    required String status,
    required bool isWarning,
  }) {
    final ratio = (enrolled / capacity).clamp(0.0, 1.0);
    final color = isWarning ? AppTheme.amberWarning : AppTheme.emeraldGreen;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$code: $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('$enrolled / $capacity Seats ($status)', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppTheme.cardSurfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  static TableRow _buildStudentRow(
    BuildContext context, {
    required String name,
    required String program,
    required String gpa,
    required String risk,
    required bool isCritical,
  }) {
    final color = isCritical ? AppTheme.roseDanger : AppTheme.amberWarning;

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        Padding(padding: const EdgeInsets.all(10), child: Text(program, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
        Padding(padding: const EdgeInsets.all(10), child: Text(gpa, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color))),
        Padding(padding: const EdgeInsets.all(10), child: Text(risk, style: TextStyle(fontSize: 11, color: color))),
        Padding(
          padding: const EdgeInsets.all(6),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dispatched AI 14-day recovery plan to $name')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryViolet,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Send Recovery Plan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
