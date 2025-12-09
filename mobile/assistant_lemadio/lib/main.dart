import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/connectivity_service.dart';

// Providers
import 'providers/chat_provider.dart';

// Pages
import 'pages/onboarding_page.dart'; // 🆕
import 'pages/chat_page.dart';

// Theme
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les services
  final storageService = StorageService();
  final apiService = ApiService();
  final connectivityService = ConnectivityService();

  // Vérifier la connectivité initiale
  await connectivityService.checkConnectivity();

  // Vérifier si l'onboarding est complété
  final onboardingCompleted = await storageService.isOnboardingCompleted();

  runApp(
    MyApp(
      storageService: storageService,
      apiService: apiService,
      connectivityService: connectivityService,
      showOnboarding: !onboardingCompleted, 
    ),
  );
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final ApiService apiService;
  final ConnectivityService connectivityService;
  final bool showOnboarding; 

  const MyApp({
    super.key,
    required this.storageService,
    required this.apiService,
    required this.connectivityService,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Service Providers
        ChangeNotifierProvider.value(value: connectivityService),
        Provider.value(value: storageService),
        // Chat Provider
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            apiService: apiService,
            storageService: storageService,
            connectivityService: connectivityService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Lemadio Formation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: showOnboarding ? const OnboardingPage() : const ChatPage(),
      ),
    );
  }
}
