// lib/screens/enhanced_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/voice_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  String _timeFrame = 'week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
        children: [
            _buildHeader(),
            Expanded(
            child: Consumer<DashboardProvider>(
                builder: (context, provider, _) {
                if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView( // Added this wrapper
                    child: Column(
                    children: [
                        _buildTimeFrameSelector(),
                        Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                            builder: (context, constraints) {
                            return Wrap( // Changed to Wrap
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                SizedBox(
                                    width: constraints.maxWidth > 600 
                                        ? (constraints.maxWidth - 16) / 2 
                                        : constraints.maxWidth,
                                    child: _buildMetricCard(
                                    title: 'Total Conversations',
                                    value: provider.metrics['totalConversations']['value'].toString(),
                                    trend: provider.metrics['totalConversations']['trend'].toDouble(),
                                    icon: Icons.message,
                                    color: Colors.blue,
                                    ),
                                ),
                                SizedBox(
                                    width: constraints.maxWidth > 600 
                                        ? (constraints.maxWidth - 16) / 2 
                                        : constraints.maxWidth,
                                    child: _buildMetricCard(
                                    title: 'Avg Sentiment',
                                    value: provider.metrics['avgSentiment']['value'].toString(),
                                    trend: provider.metrics['avgSentiment']['trend'].toDouble(),
                                    icon: Icons.favorite,
                                    color: Colors.red,
                                    ),
                                ),
                                ],
                            );
                            },
                        ),
                        ),
                        _buildSentimentChart(provider),
                        _buildProductMatches(provider),
                        _buildTriggerWords(provider),
                        _buildCustomerSegments(provider),
                    ],
                    ),
                );
                },
            ),
            ),
            _buildBottomNav(context),
        ],
        ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your conversation insights and patterns',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['day', 'week', 'month'].map((frame) {
          final isActive = _timeFrame == frame;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(frame.toUpperCase()),
              selected: isActive,
              onSelected: (selected) => setState(() => _timeFrame = frame),
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricsSection(DashboardProvider provider) {
    return Container(
        margin: const EdgeInsets.all(16),
        height: 120,
        child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
            SizedBox(
            width: 280,
            child: _buildMetricCard(
                title: 'Total Conversations',
                value: '${provider.metrics['totalConversations']['value']}',
                trend: provider.metrics['totalConversations']['trend'].toDouble(),
                icon: Icons.message,
                color: Colors.blue,
            ),
            ),
            const SizedBox(width: 16),
            SizedBox(
            width: 280,
            child: _buildMetricCard(
                title: 'Avg Sentiment',
                value: '${provider.metrics['avgSentiment']['value']}',
                trend: provider.metrics['avgSentiment']['trend'].toDouble(),
                icon: Icons.sentiment_satisfied_alt,
                color: Colors.purple,
            ),
            ),
            const SizedBox(width: 16),
            SizedBox(
            width: 280,
            child: _buildMetricCard(
                title: 'Product Match Rate',
                value: '${provider.metrics['productMatchRate']['value']}%',
                trend: provider.metrics['productMatchRate']['trend'].toDouble(),
                icon: Icons.analytics,
                color: Colors.green,
            ),
            ),
        ],
        ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required double trend,
    required IconData icon,
    required Color color,
    }) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
            BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
            ),
        ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Row(
                children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                    title,
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                    ),
                    ),
                ],
                ),
                Row(
                children: [
                    Icon(
                    trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: trend >= 0 ? Colors.green[600] : Colors.red[600],
                    ),
                    Text(
                    '${trend.abs()}%',
                    style: TextStyle(
                        color: trend >= 0 ? Colors.green[600] : Colors.red[600],
                        fontSize: 12,
                    ),
                    ),
                ],
                ),
            ],
            ),
            const SizedBox(height: 16),
            Text(
            value,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
            ),
            ),
        ],
        ),
    );
  }

  Widget _buildSentimentChart(DashboardProvider provider) {
    return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                const Text(
                'Sentiment Trends',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                ),
                ),
                Row(
                children: [
                    Icon(Icons.psychology,
                        size: 16, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    const Text(
                    'AI Analysis',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                    ),
                    ),
                ],
                ),
            ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
                width: max(MediaQuery.of(context).size.width - 32, 400),
                height: 240,
                child: LineChart(
                LineChartData(
                    gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                    ),
                    ),
                    titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) => Text(
                            provider.sentimentData[value.toInt()]['date'] ?? '',
                            style: const TextStyle(fontSize: 10),
                        ),
                        ),
                    ),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 30,
                        ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (provider.sentimentData.length - 1).toDouble(),
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                    LineChartBarData(
                        spots: provider.sentimentData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value['positive'].toDouble(),
                                ))
                            .toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                        spots: provider.sentimentData
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value['neutral'].toDouble(),
                                ))
                            .toList(),
                        isCurved: true,
                        color: Colors.grey,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
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

  Widget _buildProductMatches(DashboardProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Product Matches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...provider.productRecommendations.map((product) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product['name']),
                  Text('${product['matches']} matches'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: product['confidence'] / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${product['confidence']}% confidence',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTriggerWords(DashboardProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Common Trigger Words',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.topTriggerWords.map((word) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                word['word'],
                style: TextStyle(
                  fontSize: 14.0 + (word['count'] as num).toDouble() / 10,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSegments(DashboardProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Segments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...provider.customerSegments.map((segment) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(segment['segment']),
                  Text('${segment['percentage']}%'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: segment['percentage'] / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple[600]!,
                ),
              ),
              const SizedBox(height: 16),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
            _buildNavItem(
            icon: Icons.home, 
            label: 'Home',
            onTap: () => Navigator.pushNamed(context, '/home')
            ),
            _buildNavItem(
            icon: Icons.people,
            label: 'Customers', 
            onTap: () => Navigator.pushNamed(context, '/customers')
            ),
            Container(
            width: 85,
            height: 85,
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
                children: [
                Expanded(
                    child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                        ),
                        ],
                    ),
                    child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 32,
                    ),
                    ),
                ),
                const SizedBox(height: 4),
                const Text(
                    'Assistant',
                    style: TextStyle(fontSize: 12),
                ),
                ],
            ),
            ),
            _buildNavItem(
            icon: Icons.chat_bubble,
            label: 'Interactions',
            onTap: () => Navigator.pushNamed(context, '/interactions')
            ),
            _buildNavItem(
            icon: Icons.more_horiz,
            label: 'More',
            onTap: () => _showMoreMenu(context)
            ),
        ],
        ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            ListTile(
            leading: const Icon(Icons.rule_folder),
            title: const Text('Compliance'),
            onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/compliance');
            },
            ),
            ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
            },
            ),
            ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
                Navigator.pop(context);
                // TODO: Add settings route
            },
            ),
        ],
        ),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, color: Colors.grey),
        itemBuilder: (context) => [
        _buildMenuItem('Compliance', Icons.rule_folder, '/compliance'),
        _buildMenuItem('Dashboard', Icons.dashboard, '/dashboard'),
        _buildMenuItem('Settings', Icons.settings, null),
        ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String label, IconData icon, String? route) {
    return PopupMenuItem<String>(
        value: route,
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
        child: Row(
        children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label),
        ],
        ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
    }) {
    final color = isActive ? Theme.of(context).primaryColor : Colors.grey;
    return GestureDetector(
        onTap: onTap,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(icon, color: color),
            Text(
            label,
            style: TextStyle(
                color: color,
                fontSize: 12,
            ),
            ),
        ],
        ),
    );
  }

  Widget _buildFloatingMic() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<VoiceProvider>(
          builder: (context, voiceProvider, _) => GestureDetector(
            onTap: () {
              if (voiceProvider.isListening) {
                voiceProvider.stopListening();
              } else {
                voiceProvider.startListening();
              }
            },
            child: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: voiceProvider.isListening
                    ? const Color(0xFF991B1B)
                    : Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        const Text(
          'Assistant',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}