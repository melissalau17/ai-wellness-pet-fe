import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/pet_provider.dart';
import '../widgets/bottom_nav.dart';

/// The "Garden" tab doubles as a handy spot for the backend's demo-only
/// endpoints (reset / simulate neglect) so you can showcase pet states
/// during a demo without waiting for real score changes.
class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetProvider>();
    final pet = provider.pet;

    return Scaffold(
      appBar: buildMelloAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Garden',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Coming soon: watch your garden grow as ${pet?.petName ?? 'your pet'} thrives.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
            const SizedBox(height: 24),

            // Current pet status summary
            if (pet != null)
              SoftCard(
                color: AppColors.mintSoft,
                child: Row(
                  children: [
                    const Icon(Icons.pets_rounded,
                        size: 32, color: AppColors.mintDark),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.petName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 17),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Health: ${pet.healthScore}%  •  Energy: ${pet.energyScore}%  •  ${pet.currentState}',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            const Divider(),
            const SizedBox(height: 8),
            const Text('Demo Tools',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            const Text(
              'For testing & demo purposes — quickly change pet state.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await provider.resetPet();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Pet reset to 50/50 Neutral ✅'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset Pet'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await provider.simulateNeglect();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Pet is now neglected: 20/20 Sad 😢'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: const Text('Simulate Neglect'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out?'),
                      content: const Text(
                          'This will clear your data and return to onboarding.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Log Out',
                              style: TextStyle(color: AppColors.redText)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    try {
                      await context.read<PetProvider>().logout();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logout failed: $e')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.logout_rounded,
                    size: 18, color: AppColors.redText),
                label: const Text('Log Out',
                    style: TextStyle(color: AppColors.redText)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
