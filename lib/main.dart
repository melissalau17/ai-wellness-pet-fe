import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/pet_provider.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(MelloApp(apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'https://ai-wellness-pet.onrender.com/api/v1'));
}

class MelloApp extends StatelessWidget {
  final String apiBaseUrl;
  const MelloApp({super.key, required this.apiBaseUrl});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PetProvider(ApiService(baseUrl: apiBaseUrl))
        ..loadFromStorage(),
      child: MaterialApp(
        title: "Mello",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, provider, _) {
        if (provider.userId == null && !provider.onboarded) {
          return const OnboardingScreen();
        }
        if (provider.onboarded) {
          return const AppShell();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
