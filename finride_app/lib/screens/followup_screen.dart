// lib/screens/followup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final List<Map<String, dynamic>> rideHistory = [
    {
      "customer": "Sarah Chen",
      "date": "2024-01-28",
      "notes": "Interested in savings account",
      "status": "Pending Follow-up"
    }
  ];

  final List<Map<String, dynamic>> templates = [
    {
      "id": "savings_info",
      "title": "Savings Account Info",
      "message": "Hi [name], as discussed during our ride, here's information about our savings account with 5% interest rate."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildQuickActions(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecentRides(),
                  _buildMessageTemplates(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
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
                    'Follow-ups',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (voiceProvider.isListening) {
                        voiceProvider.stopListening();
                      } else {
                        voiceProvider.listen();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: voiceProvider.isListening 
                          ? const Color(0xFF991B1B) 
                          : const Color(0xFFDC2626),
                      ),
                      child: Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 24,
                        semanticLabel: voiceProvider.isListening 
                          ? 'Stop Recording' 
                          : 'Start Recording',
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Say "Schedule follow-up with [name]"',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.send,
              label: 'Send Now',
              color: Theme.of(context).primaryColor,
              onTap: () {
                // Implement send action
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              icon: Icons.calendar_today,
              label: 'Schedule',
              color: const Color(0xFF1D4ED8), // blue-700
              onTap: () {
                // Implement schedule action
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRides() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Rides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          ...rideHistory.map((ride) => _buildRideCard(ride)).toList(),
        ],
      ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Color(0xFF7C3AED), // purple-700
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ride['customer'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.schedule, size: 20, color: Colors.grey),
              ],
            ),
            Text(
              ride['notes'],
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRideActionButton(
                    label: 'Send Info',
                    color: Theme.of(context).primaryColor,
                    onTap: () {
                      // Implement send info action
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRideActionButton(
                    label: 'Set Reminder',
                    color: const Color(0xFF1D4ED8), // blue-700
                    onTap: () {
                      // Implement set reminder action
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget _buildMessageTemplates() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Templates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          ...templates.map((template) => _buildTemplateCard(template)).toList(),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Colors.grey,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  template['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.check, size: 20, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              template['message'],
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}