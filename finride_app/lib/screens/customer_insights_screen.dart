// lib/screens/customer_insights_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';
import '../providers/voice_provider.dart';

class CustomerInsightsScreen extends StatefulWidget {
  const CustomerInsightsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerInsightsScreen> createState() => _CustomerInsightsScreenState();
}

class _CustomerInsightsScreenState extends State<CustomerInsightsScreen> {
  String _searchQuery = '';
  Customer? _selectedCustomer;
  late double _age;
  late double _aum;

  @override
  void initState() {
    super.initState();
    _age = 0;
    _aum = 0;
    Future.microtask(() {
      context.read<CustomerProvider>().loadCustomers();
    });
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
                'Customer Insights',
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
                    icon: const Icon(Icons.psychology, color: Colors.white),
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
              hintText: 'Search insights...',
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

  Widget _buildCustomerCard(Customer customer) {
    final color = customer.businessInsights.status == 'high_potential' ? Colors.purple : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => setState(() {
          _selectedCustomer = customer;
          _age = customer.businessInsights.age.toDouble();
          _aum = customer.businessInsights.aum;
        }),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Segment: ${customer.businessInsights.segment}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      customer.businessInsights.industry,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age: ${customer.businessInsights.age}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'AUM: ${customer.businessInsights.aum} billion VND',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(Customer customer) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer.name);
    final segmentController = TextEditingController(text: customer.businessInsights.segment);
    final industryController = TextEditingController(text: customer.businessInsights.industry);
    final statusController = TextEditingController(text: customer.businessInsights.status);
    final financialGoalsController = TextEditingController(
      text: customer.financialGoals.join('\n')
    );

    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            customer.businessInsights.segment,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Edit Customer'),
                            content: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: nameController,
                                      decoration: const InputDecoration(labelText: 'Name'),
                                      validator: (value) => 
                                        value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: segmentController.text.isEmpty ? 'Unknown' : segmentController.text,
                                      decoration: const InputDecoration(labelText: 'Segment'),
                                      items: ['Business Owner', 'Household', 'Payroll', 'Unknown']
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                        .toList(),
                                      onChanged: (value) => segmentController.text = value!,
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: industryController.text.isEmpty ? 'Unknown' : industryController.text,
                                      decoration: const InputDecoration(labelText: 'Industry'),
                                      items: ['Retail', 'Technology', 'Manufacturing', 'Services', 'Unknown']
                                        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                                        .toList(),
                                      onChanged: (value) => industryController.text = value!,
                                    ),
                                    const SizedBox(height: 16),
                                    StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Age: ${_age.toInt()}',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                Slider(
                                                  value: _age,
                                                  min: 0,
                                                  max: 100,
                                                  divisions: 100,
                                                  label: _age.toString(),
                                                  onChanged: (value) {
                                                    setStateDialog(() {
                                                      _age = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'AUM: ${_aum.toStringAsFixed(1)} billion VND',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                Slider(
                                                  value: _aum,
                                                  min: 0,
                                                  max: 100,
                                                  divisions: 1000,
                                                  label: _aum.toStringAsFixed(1),
                                                  onChanged: (value) {
                                                    setStateDialog(() {
                                                      _aum = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: statusController.text.isEmpty ? 'Unknown' : statusController.text,
                                      decoration: const InputDecoration(labelText: 'Status'),
                                      items: ['high_potential', 'medium', 'low', 'Unknown']
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                        .toList(),
                                      onChanged: (value) => statusController.text = value!,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: financialGoalsController,
                                      decoration: const InputDecoration(
                                        labelText: 'Financial Goals (one per line)',
                                        helperText: 'Enter each goal on a new line'
                                      ),
                                      maxLines: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ?? false) {
                                    await context.read<CustomerProvider>()
                                      .updateCustomer({
                                        "phone_number": customer.phoneNumber,
                                        "name": nameController.text,
                                        "businessInsights": {
                                          "segment": segmentController.text,
                                          "industry": industryController.text,
                                          "age": _age.toInt(),
                                          "aum": _aum,
                                          "status": statusController.text
                                        },
                                        "financialGoals": financialGoalsController.text
                                          .split('\n')
                                          .where((goal) => goal.isNotEmpty)
                                          .toList()
                                      });
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _selectedCustomer = null);
                        context.read<CustomerProvider>().loadCustomers(); // Reload customers to reflect new values
                      },
                    ),
                  ],
                ),
              ),

              // Profile Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBusinessDetail(
                      'Industry',
                      customer.businessInsights.industry,
                    ),
                    _buildBusinessDetail(
                      'Age',
                      customer.businessInsights.age.toString(),
                    ),
                    _buildBusinessDetail(
                      'AUM',
                      '${customer.businessInsights.aum} billion VND',
                    ),
                  ],
                ),
              ),

              // Financial Goals Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: customer.financialGoals.map((goal) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.track_changes,
                                  size: 16, color: Colors.purple[600]),
                                const SizedBox(width: 8),
                                Text(goal),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Next Best Offers Section
              if (customer.nbo != null && customer.nbo!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Best Offers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...customer.nbo!.map((product) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product.product,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${product.confidence.round()}% Match',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (product.reasons.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...product.reasons.map((reason) => Text(
                                '• $reason',
                                style: const TextStyle(fontSize: 12),
                              )),
                            ],
                          ],
                        ),
                      )),
                    ],
                  ),
                ),

              // Next Best Actions Section  
              if (customer.nba != null && customer.nba!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Best Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...customer.nba!.map((action) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action.action,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Due: ${action.deadline}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: action.priority == 'high'
                                  ? Colors.red[50]
                                  : Colors.orange[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                action.priority.toUpperCase(),
                                style: TextStyle(
                                  color: action.priority == 'high'
                                    ? Colors.red[700]
                                    : Colors.orange[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Follow-up'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.update, size: 16),
                        label: const Text('Status'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
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
            child: Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                if (provider.customers == null) {
                  return const Center(child: Text('No customers found'));
                }

                final filteredCustomers = provider.customers!
                    .where((customer) =>
                        customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        customer.businessInsights.segment.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                return _selectedCustomer != null
                    ? SingleChildScrollView(
                        child: _buildCustomerDetails(_selectedCustomer!),
                      )
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) =>
                            _buildCustomerCard(filteredCustomers[index]),
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
            voiceProvider.isListening 
                ? voiceProvider.stopListening() 
                : voiceProvider.startListening();
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