// lib/screens/interaction_insights_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conversation_provider.dart';
import '../models/ride_interaction.dart';
import '../models/customer.dart';
import '../models/conversation_analysis.dart';
import '../models/next_step.dart';
import '../providers/voice_provider.dart';

class InteractionInsightsScreen extends StatefulWidget {
  const InteractionInsightsScreen({Key? key}) : super(key: key);

  @override
  State<InteractionInsightsScreen> createState() => _InteractionInsightsScreenState();
}

class _InteractionInsightsScreenState extends State<InteractionInsightsScreen> {
  String _searchQuery = '';
  String _timeFilter = 'recent';
  String _activeTab = 'summary';
  int? _selectedInteractionId; // Add this
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ConversationProvider>();
      provider.loadInteractions();
    });
  }

  void _loadData() async {
    final provider = context.read<ConversationProvider>();
    await provider.loadInteractions();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'After Ride Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              hintText: 'Search conversations...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['recent', 'today', 'pending', 'completed'].map((filter) {
          final isActive = _timeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.toUpperCase()),
              selected: isActive,
              onSelected: (selected) => setState(() => _timeFilter = filter),
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

  Widget _buildRideCard(RideInteraction ride) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedInteractionId = ride.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${ride.date} • ${ride.platform}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ride.conversationAnalysis?.summary != null) ...[
                const SizedBox(height: 16),
                ...ride.conversationAnalysis!.summary.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 8),
                      const SizedBox(width: 8),
                      Expanded(child: Text(point)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'high_potential':
        color = Colors.green;
        break;
      case 'needs_review':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(RideInteraction ride) {
    switch (_activeTab) {
      case 'summary':
        return _buildSummaryContent(ride);
      case 'products':
        return _buildProductsContent(ride);
      case 'next-steps':
        return _buildNextStepsContent(ride);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSummaryContent(RideInteraction ride) {
    final analysis = ride.conversationAnalysis;
    if (analysis == null) {
        return const Center(
        child: Text('Analysis in progress...'),
        );
    }

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conversation Highlights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...analysis.summary.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(point),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology,
                        color: Colors.purple[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Key Topics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...analysis.keyTopics.map((topic) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(topic.topic),
                        Text('${topic.confidence.round()}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: topic.confidence / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.purple[700]!,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsContent(RideInteraction ride) {
    final products = ride.conversationAnalysis?.productMatches ?? [];
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
        final product = products[index];
        return Card(
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(
                        product.product,
                        style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                        ),
                        decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                        '${product.confidence.round()}% Match',
                        style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                        ),
                        ),
                    ),
                    ],
                ),
                const SizedBox(height: 16),
                const Text(
                    'Why This Product?',
                    style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    ),
                ),
                const SizedBox(height: 8),
                ...product.reasons.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                    children: [
                        Icon(Icons.check,
                            color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(reason)),
                    ],
                    ),
                )),
                const SizedBox(height: 16),
                const Text(
                    'Key Features',
                    style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.features.map((feature) => 
                        Chip(
                        label: Text(
                            feature,
                            style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[100],
                        )
                    ).toList(),
                    ),
                ),
                const SizedBox(height: 16),
                Row(
                    children: [
                    Expanded(
                        child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Send Information'),
                        ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Schedule Call'),
                        ),
                    ),
                    ],
                ),
                ],
            ),
            ),
        );
        },
    );
  }

  Widget _buildNextStepsContent(RideInteraction ride) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ride.nextSteps.length,
      itemBuilder: (context, index) {
        final step = ride.nextSteps[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          step.action,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: step.priority == 'high'
                            ? Colors.red[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        step.priority.toUpperCase(),
                        style: TextStyle(
                          color: step.priority == 'high'
                              ? Colors.red[700]
                              : Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Complete ${step.deadline}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Mark Complete'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<ConversationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                final interactions = provider.interactions;
                if (interactions.isEmpty) {
                  return const Center(child: Text('No interactions found'));
                }

                final latestInteraction = interactions.last;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              latestInteraction.customer.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${latestInteraction.date} • ${latestInteraction.platform}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (latestInteraction.conversationAnalysis?.summary != null)
                        ...latestInteraction.conversationAnalysis!.summary.map((point) =>
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.circle, size: 8, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                Expanded(child: Text(point)),
                              ],
                            ),
                          ),
                        ),
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