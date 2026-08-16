import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/pet_provider.dart';
import '../widgets/bottom_nav.dart';
import 'activities_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().refreshPet();
    });
  }

  IconData _moodIcon(String state) {
    switch (state) {
      case 'Happy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'Tired':
        return Icons.sentiment_dissatisfied_rounded;
      case 'Sad':
        return Icons.sentiment_very_dissatisfied_rounded;
      default:
        return Icons.sentiment_satisfied_rounded;
    }
  }

  /// Returns the asset path for known pet characters, or null.
  static const _petAssets = {
    'Milo': 'images/pets/milo.jpg',
    'Luna': 'images/pets/luna.jpg',
    'Bear': 'images/pets/bear.jpg',
  };
  String? _petAsset(String name) => _petAssets[name];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetProvider>();
    final pet = provider.pet;
    final petName = pet?.petName ?? 'Milo';
    final state = pet?.currentState ?? 'Neutral';
    final health = pet?.healthScore ?? 50;
    final energy = pet?.energyScore ?? 50;

    return Scaffold(
      appBar: buildMelloAppBar(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: AppColors.mintDark,
        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
        label: Text(
          'Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: provider.refreshPet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet portrait + mood badge.
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mintSoft,
                            border: Border.all(color: AppColors.mint, width: 3),
                          ),
                          child: ClipOval(
                            child: _petAsset(petName) != null
                                ? Image.asset(
                                    _petAsset(petName)!,
                                    width: 220,
                                    height: 220,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(_moodIcon(state),
                                    size: 100, color: AppColors.mintDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      petName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MoodPill.fromState(state),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Speech bubble with the latest AI message.
              SoftCard(
                color: AppColors.blueSoft,
                child: Text(
                  '"${provider.lastAiMessage}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDeep,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _StatBar(
                icon: Icons.favorite_rounded,
                label: 'Health',
                value: health,
                color: AppColors.mint,
              ),
              const SizedBox(height: 16),
              _StatBar(
                icon: Icons.bolt_rounded,
                label: 'Energy',
                value: energy,
                color: AppColors.tan,
                valueColor: AppColors.tanText,
              ),
              const SizedBox(height: 28),

              const Text('Quick Actions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.water_drop_rounded,
                      title: 'Log Water',
                      subtitle: '${provider.draftWater}/8 Glasses',
                      selected: true,
                      onTap: () => _goToActivities(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionTile(
                      icon: Icons.nightlight_round,
                      title: 'Sleep Log',
                      subtitle:
                          '${provider.draftSleepHours.toStringAsFixed(1)} hrs logged',
                      onTap: () => _goToActivities(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _QuickActionTile(
                icon: Icons.edit_note_rounded,
                title: 'Daily Journal',
                subtitle: 'How are you feeling, friend?',
                fullWidth: true,
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () => _goToActivities(context),
              ),

              if (provider.error != null) ...[
                const SizedBox(height: 16),
                Text(provider.error!,
                    style: const TextStyle(color: AppColors.redText)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _goToActivities(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ActivitiesScreen()),
    );
  }
}

class _StatBar extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value; // 0-100
  final Color color;
  final Color? valueColor;

  const _StatBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: valueColor ?? AppColors.mintDark),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const Spacer(),
            Text('$value%',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 10,
            backgroundColor: AppColors.blueSoft,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool fullWidth;
  final Widget? trailing;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.fullWidth = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueSoft : AppColors.bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 18, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
      ),
    );
  }
}
