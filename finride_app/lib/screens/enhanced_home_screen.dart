// lib/screens/enhanced_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';
import '../providers/compliance_provider.dart';
import '../services/api_service.dart';
import '../services/instant_assistant_service.dart';
import 'package:permission_handler/permission_handler.dart';

class RidePhase {
  static const String idle = 'idle';
  static const String leadCapture = 'lead_capture';
  static const String enRoute = 'en_route';
  static const String inRide = 'in_ride';
  static const String customerData = 'customer_data'; // New phase
  static const String completed = 'completed';
}

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  Map<String, dynamic> _customerData = {};
  String? _platform = 'Xanh SM';
  String _ridePhase = RidePhase.idle;
  Map<String, dynamic>? _currentLead;
  int _recordingDuration = 0;

  late final ApiService _apiService;

  Widget _buildHeader() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, _) => Container(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        color: Theme.of(context).primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FinDrive Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: voiceProvider.isListening 
                      ? const Color(0xFF991B1B) 
                      : const Color(0xFFDC2626),
                  ),
                  child: const Icon(Icons.mic, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusText(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (_ridePhase) {
      case RidePhase.idle:
        return 'Ready for new ride';
      case RidePhase.leadCapture:
        return 'Capturing lead details';
      case RidePhase.enRoute:
        return 'En route to pickup';
      case RidePhase.inRide:
        return 'Recording conversation';
      case RidePhase.completed:
        return 'Ride completed';
      default:
        return '';
    }
  }

  Widget _buildIdleState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => setState(() => _ridePhase = RidePhase.leadCapture),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, 
                color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'New Ride Request',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCaptureForm() {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [
            Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                children: [
                    TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                    ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Passenger Name',
                        border: OutlineInputBorder(),
                    ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                        labelText: 'Pickup Location',
                        border: OutlineInputBorder(),
                    ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Platform',
                        border: OutlineInputBorder(),
                    ),
                    value: _platform,
                    items: ['Xanh SM', 'Grab', 'Be']
                        .map((String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                        )).toList(),
                    onChanged: (value) => setState(() => _platform = value),
                    ),
                ],
                ),
            ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
            onPressed: _handleNewRide,
            child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text('Confirm Lead'),
                ],
                ),
            ),
            ),
        ],
        ),
    );
  }

  Widget _buildEnRouteState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Passenger',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentLead?['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    _currentLead?['location'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _ridePhase = RidePhase.inRide);
              assistantService.startRecordingAssistant(); // Start recording when the button is pressed
            },
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Start Instant Assistant'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInRideState() {
    final assistantService = Provider.of<InstantAssistantService>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recording',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${_recordingDuration ~/ 60}:${(_recordingDuration % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      assistantService.liveTranscript.isEmpty
                          ? 'No transcript yet.'
                          : assistantService.liveTranscript,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _currentLead?['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  _currentLead?['location'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _completeRide(assistantService),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
            ),
            child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text('Complete Ride'),
                ],
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ride Completed',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'After Ride Workflow and Compliance check initiated.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.assessment,
                  label: 'After Ride\nWorkflow',
                  onTap: () => _navigateToAnalysis(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.verified_user,
                  label: 'Compliance\nCheck',
                  onTap: () => _navigateToCompliance(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildMainContent(),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_ridePhase) {
        case RidePhase.idle:
        return _buildIdleState();
        case RidePhase.leadCapture:
        return _buildLeadCaptureForm();
        case RidePhase.enRoute:
        return _buildEnRouteState();
        case RidePhase.inRide:
        return _buildInRideState();
        case RidePhase.customerData:
        return _buildCustomerDataForm(); 
        case RidePhase.completed:
        return _buildCompletedState();
        default:
        return const SizedBox.shrink();
    }
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

  Widget _buildCustomerDataForm() {
    return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
        children: [
        Card(
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                children: [
                DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                    labelText: 'Segment',
                    border: OutlineInputBorder(),
                    ),
                    items: ['Business Owner', 'Household', 'Payroll']
                    .map((String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                    )).toList(),
                    onChanged: (value) => _customerData['segment'] = value,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age: ${_customerData['age']?.toString() ?? ""}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: _customerData['age']?.toDouble() ?? 0,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: _customerData['age']?.toString(),
                      onChanged: (value) {
                        setState(() {
                          _customerData['age'] = value.toInt();
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
                      'AUM: ${_customerData['aum']?.toStringAsFixed(1) ?? ""} billion VND',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: _customerData['aum']?.toDouble() ?? 0,
                      min: 0,
                      max: 100,
                      divisions: 1000,
                      label: _customerData['aum']?.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _customerData['aum'] = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                    labelText: 'Industry',
                    border: OutlineInputBorder(),
                    ),
                    items: ['Retail', 'Technology', 'Manufacturing', 'Services']
                    .map((String value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                    )).toList(),
                    onChanged: (value) => _customerData['industry'] = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                    decoration: const InputDecoration(
                    labelText: 'Financial Goals (comma separated)',
                    border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _customerData['financialGoals'] = value.split(','),
                ),
                ],
            ),
            ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
            onPressed: _handleCustomerData,
            child: const Text('Save Customer Data'),
        ),
        ],
    ),
    );
  }

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
    if (_ridePhase == RidePhase.inRide) {
        _startRecordingTimer();
    }
  }

  void requestMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      // The microphone permission is granted.
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _ridePhase == RidePhase.inRide) {
        setState(() {
          _recordingDuration++;
        });
        _startRecordingTimer();
      }
    });
  }

  Future<void> _handleNewRide() async {
    try {
        final customer = await _apiService.createOrUpdateCustomer({
        "phone_number": _phoneController.text,
        "name": _nameController.text,
        "location": _locationController.text,
        });

        final interaction = await _apiService.createNewInteraction({
        "customer": customer,
        "timestamp": DateTime.now().toIso8601String(),
        "date": DateTime.now().toString().split(' ')[0],
        "platform": _platform,
        });

        setState(() {
        _ridePhase = RidePhase.enRoute;
        _currentLead = {
            'name': customer['name'],
            'location': customer['location'],
        };
        });
    } catch (e) {
        print('Error creating ride: $e');
    }
  }

  // Add handler method
  void _handleCustomerData() async {
    try {
      final customer = await _apiService.createOrUpdateCustomer({
        "phone_number": _phoneController.text,
        "name": _nameController.text,
        "businessInsights": {
          "segment": _customerData['segment'],
          "age": _customerData['age'],
          "aum": _customerData['aum'],
          "industry": _customerData['industry'],
          "status": _customerData['status'],
        },
        "financialGoals": _customerData['financialGoals'],
        // Add any additional fields if necessary
      });

      final interactionData = await assistantService._chatGptProcess(
         assistantService.liveTranscript,
         "Generate interaction data model from the conversation:"
      );

      final interaction = await _apiService.createNewInteraction({
          "customer": customer,
          "timestamp": DateTime.now().toIso8601String(),
          "date": DateTime.now().toString().split(' ')[0],
          "platform": _platform,
          ...interactionData,
      });

      setState(() => _ridePhase = RidePhase.completed);
    } catch (e) {
      print('Error saving customer data: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving customer data: $e')),
      );
    }
  }

  void _completeRide() {
    setState(() => _ridePhase = RidePhase.customerData);
    // Refresh compliance data once customer data is saved
    context.read<ComplianceProvider>().loadCurrentRideCompliance();
  }

  void _navigateToAnalysis() {
    Navigator.pushNamed(context, '/interactions');
  }

  void _navigateToCompliance() {
    Navigator.pushNamed(context, '/compliance');
  }

  void _navigateToCustomers() {
    Navigator.pushNamed(context, '/customers'); // Update route name to match customer insights screen
  }

  void _navigateToChat() {
    Navigator.pushNamed(context, '/chat');
  }

  void _navigateToStats() {
    Navigator.pushNamed(context, '/stats');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}