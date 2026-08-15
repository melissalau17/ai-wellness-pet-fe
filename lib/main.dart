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
  runApp(const MilosCornerApp());
}

class MilosCornerApp extends StatelessWidget {
  const MilosCornerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['API_BASE_URL'] ??
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://ai-wellness-pet.onrender.com/api/v1',
        );

    return ChangeNotifierProvider(
      create: (_) => PetProvider(ApiService(baseUrl: baseUrl))
        ..loadFromStorage(),
      child: MaterialApp(
        title: "Milo's Corner",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _RootRouter(),
      ),
    );
  }
}

/// Shows a splash while local storage loads, then routes to onboarding
/// or straight into the app shell depending on whether setup is done.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, provider, _) {
        if (provider.userId == null && !provider.onboarded) {
          // Still might be loading from storage on first frame; a tiny
          // splash avoids a flash of the onboarding screen.
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
