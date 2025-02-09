// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/customer_provider.dart';
import 'providers/voice_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/product_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/compliance_provider.dart';
import 'screens/enhanced_home_screen.dart';
import 'screens/interaction_insights_screen.dart';
import 'screens/customer_insights_screen.dart';
import 'screens/enhanced_dashboard_screen.dart';
import 'screens/compliance_guidelines_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => VoiceProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ConversationProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ComplianceProvider(context.read<ApiService>()),
        ),
      ],
      child: MaterialApp(
        title: 'FinRide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFB91C1C),
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFB91C1C),
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const EnhancedHomeScreen(),
        routes: {
            '/home': (context) => const EnhancedHomeScreen(),
            '/customers': (context) => const CustomerInsightsScreen(),
            '/interactions': (context) => const InteractionInsightsScreen(), // Renamed from AfterRideAnalysisScreen
            '/dashboard': (context) => const EnhancedDashboardScreen(),
            '/compliance': (context) => const ComplianceGuidelinesScreen(),
        },
      ),
    );
  }
}