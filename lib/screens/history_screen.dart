import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/pet_provider.dart';
import '../widgets/bottom_nav.dart';
import '../models/daily_log.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().refreshHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetProvider>();
    final logs = provider.history;

    return Scaffold(
      appBar: buildMelloAppBar(context),
      body: RefreshIndicator(
        onRefresh: provider.refreshHistory,
        child: logs.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const _Header(),
                  const SizedBox(height: 60),
                  Center(
                    child: Text(
                      'No entries yet.\nCheck in with ${provider.pet?.petName ?? 'your pet'} to start your journey!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: logs.length + 2,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) return const _Header();
                  if (index == logs.length + 1) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          'That\'s the last 10 entries.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    );
                  }
                  return _LogCard(log: logs[index - 1]);
                },
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().pet;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Journey',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text("A look back at ${pet?.petName ?? 'your pet'}'s recent days.",
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final DailyLog log;
  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(log.createdAt);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              MoodPill.fromState(_stateForMood(log.displayMood)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (log.waterGlasses > 0)
                _MiniIcon(icon: Icons.water_drop_rounded, color: AppColors.blueDeep),
              if (log.sleepHours > 0) ...[
                const SizedBox(width: 8),
                _MiniIcon(icon: Icons.nightlight_round, color: AppColors.tanText),
              ],
              if (log.journalText.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                _MiniIcon(icon: Icons.edit_rounded, color: AppColors.mintDark),
              ],
              const Spacer(),
              if (log.journalText.trim().isNotEmpty)
                Flexible(
                  child: Text(
                    log.journalText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Maps the display mood word back to a state MoodPill understands.
  String _stateForMood(String mood) {
    switch (mood) {
      case 'Happy':
        return 'Happy';
      case 'Tired':
        return 'Tired';
      default:
        return 'Neutral';
    }
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MiniIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: color.withOpacity(0.15),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
