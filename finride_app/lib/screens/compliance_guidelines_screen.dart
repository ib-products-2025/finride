// lib/screens/compliance_guidelines_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/compliance_provider.dart';
import '../providers/voice_provider.dart';

class ComplianceGuidelinesScreen extends StatefulWidget {
  const ComplianceGuidelinesScreen({Key? key}) : super(key: key);

  @override
  State<ComplianceGuidelinesScreen> createState() => _ComplianceGuidelinesScreenState();
}

class _ComplianceGuidelinesScreenState extends State<ComplianceGuidelinesScreen> {
  String _activeSection = 'current';
  int? _selectedRideId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ComplianceProvider>().loadCurrentRideCompliance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
        child: Consumer<ComplianceProvider>(
            builder: (context, provider, _) {
            if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
            }

            return Column(
                children: [
                _buildHeader(),
                _buildSectionTabs(),
                Expanded(
                    child: _activeSection == 'current'
                        ? _buildCurrentRide(provider)
                        : _activeSection == 'guidelines'
                            ? _buildGuidelines(provider)
                            : _buildPreviousRides(provider),
                ),
                _buildBottomNav(context),
                ],
            );
            },
        ),
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
                'Compliance Guidelines',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const Text(
            'Follow these guidelines during rides',
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

  Widget _buildSectionTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSectionTab('current', 'Current Ride'),
          _buildSectionTab('guidelines', 'Guidelines'),
          _buildSectionTab('previous', 'Previous Rides'),
        ],
      ),
    );
  }

  Widget _buildSectionTab(String id, String label) {
    final isActive = _activeSection == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (selected) => setState(() => _activeSection = id),
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Map<String, dynamic> check) {
    return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                        check['customer_name'] ?? 'Unknown Customer',
                        style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        'Ride Date: ${check['ride_date'] ?? 'N/A'}',
                        style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        ),
                    ),
                    ],
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                    ),
                    decoration: BoxDecoration(
                    color: _getStatusColor(check['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                    (check['status'] ?? 'IN REVIEW').toUpperCase(),
                    style: TextStyle(
                        color: _getStatusColor(check['status']),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                    ),
                    ),
                ),
                ],
            ),
            ],
        ),
        ),
    );
  }

  Color _getStatusColor(String? status) {
    switch(status?.toLowerCase()) {
        case 'compliant':
        return Colors.green;
        case 'non_compliant':
        return Colors.red;
        default:
        return Colors.orange;
    }
  }

  Widget _buildCurrentRide(ComplianceProvider provider) {
    if (provider.currentCheck == null) return const SizedBox.shrink();
    
    final activeChecks = provider.currentCheck!['active_compliance_checks'] as List;
    if (activeChecks.isEmpty) return const Center(child: Text('No active compliance checks'));
    
    return ListView.builder(
        // Remove shrinkWrap and use default physics
        itemCount: activeChecks.length,
        itemBuilder: (context, index) {
        final activeCheck = activeChecks[index];
        return Column(
            children: [
            _buildCustomerInfo(activeCheck),
            _buildCheckpoints(activeCheck['checkpoints']),
            ],
        );
        },
    );
  }

  Widget _buildCheckpoints(List<dynamic> checkpoints) {
    return Column(
        children: checkpoints.map((section) {
        final Map<String, dynamic> sectionData = section as Map<String, dynamic>;
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
                Text(
                sectionData['category'] as String,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ...((sectionData['items'] as List).map((item) => _buildCheckpointItem(item as Map<String, dynamic>))),
            ],
            ),
        );
        }).toList(),
    );
  }

  Widget _buildCheckpointItem(Map<String, dynamic> item) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
        children: [
            Icon(
            item['completed'] == true ? Icons.check_circle : Icons.pending,
            size: 16,
            color: item['completed'] == true ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(item['text'] as String)),
            if (item['required'] == true)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                'Required',
                style: TextStyle(color: Colors.red[800], fontSize: 12),
                ),
            ),
        ],
        ),
    );
  }

  Widget _buildGuidelines(ComplianceProvider provider) {
    final guidelines = provider.currentCheck?['guidelines'];
    if (guidelines == null) return const SizedBox.shrink();

    return SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
            children: [
            _buildGuidelineSection(
                'Do\'s',
                guidelines['doList'],
                Icons.check_circle,
                Colors.green,
            ),
            _buildGuidelineSection(
                'Don\'ts',
                guidelines['dontList'],
                Icons.cancel,
                Colors.red,
            ),
            _buildGuidelineSection(
                'Required Phrases',
                guidelines['requiredPhrases'],
                Icons.message,
                Colors.blue,
                isQuoted: true,
            ),
            // Add bottom padding to avoid navigation bar overlap
            const SizedBox(height: 80),
            ],
        ),
        ),
    );
  }

  Widget _buildGuidelineSection(
    String title,
    List<dynamic> items,
    IconData icon,
    MaterialColor color, {
    bool isQuoted = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color[700],
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: color[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isQuoted ? '"$item"' : item,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPreviousRides(ComplianceProvider provider) {
    if (provider.currentCheck == null) return const SizedBox.shrink();
    
    final previousChecks = provider.currentCheck!['previous_compliance_checks'] as List;
    
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: previousChecks.length,
        itemBuilder: (context, index) {
        final check = previousChecks[index];
        return Column(
            children: [
            _buildCustomerInfo(check),
            if (check['checkpoints'] != null)
                _buildCheckpoints(check['checkpoints']),
            ],
        );
        },
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'compliant' ? Colors.green : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color[700],
          fontSize: 12,
        ),
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