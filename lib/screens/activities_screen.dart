import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/pet_provider.dart';
import '../widgets/bottom_nav.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late final TextEditingController _journalController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PetProvider>();
    _journalController = TextEditingController(text: provider.draftJournal);
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _checkIn(PetProvider provider) async {
    provider.setDraftJournal(_journalController.text);
    final ok = await provider.checkIn();
    if (!mounted) return;
    if (ok) {
      final petName = provider.pet?.petName ?? 'Your pet';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$petName says: "${provider.lastAiMessage}"')),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetProvider>();
    const maxGlasses = 8;

    return Scaffold(
      appBar: buildMelloAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log My Wellness',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Take a moment to record your day.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
            const SizedBox(height: 20),

            // Hydration
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.blueSoft,
                        child: Icon(Icons.water_drop_rounded,
                            size: 16, color: AppColors.blueDeep),
                      ),
                      SizedBox(width: 10),
                      Text('Hydration',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundIconButton(
                        icon: Icons.remove_rounded,
                        onTap: () => provider.setDraftWater(provider.draftWater - 1),
                        color: AppColors.blueSoft,
                        iconColor: AppColors.blueDeep,
                      ),
                      Column(
                        children: [
                          Text('${provider.draftWater}',
                              style: const TextStyle(
                                  fontSize: 34, fontWeight: FontWeight.w800)),
                          const Text('glasses',
                              style: TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                      _RoundIconButton(
                        icon: Icons.add_rounded,
                        onTap: () => provider.setDraftWater(provider.draftWater + 1),
                        color: AppColors.mint,
                        iconColor: AppColors.textDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(maxGlasses, (i) {
                      final filled = i < provider.draftWater;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: filled ? AppColors.blueDeep : AppColors.blueSoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sleep
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.tan,
                        child: Icon(Icons.nightlight_round,
                            size: 15, color: AppColors.tanText),
                      ),
                      SizedBox(width: 10),
                      Text('Sleep',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration', style: TextStyle(color: AppColors.textMuted)),
                      Text('${provider.draftSleepHours.toStringAsFixed(1)} hrs',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.blueDeep,
                      inactiveTrackColor: AppColors.blueSoft,
                      thumbColor: AppColors.blueDeep,
                      overlayColor: AppColors.blueDeep.withOpacity(0.15),
                    ),
                    child: Slider(
                      value: provider.draftSleepHours,
                      min: 0,
                      max: 12,
                      divisions: 24,
                      onChanged: (v) => provider.setDraftSleep(v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('0h', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      Text('12h+', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Journal
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.red,
                        child: Icon(Icons.edit_note_rounded,
                            size: 17, color: AppColors.redText),
                      ),
                      SizedBox(width: 10),
                      Text('Journal',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _journalController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'How was your day, friend?',
                      filled: true,
                      fillColor: AppColors.bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final tag in ['#productive', '#tired', '#anxious'])
                        ActionChip(
                          label: Text(tag),
                          backgroundColor: AppColors.bg,
                          onPressed: () {
                            final text = _journalController.text;
                            _journalController.text =
                                text.isEmpty ? tag : '$text $tag';
                          },
                        ),
                      Chip(
                        label: const Icon(Icons.add, size: 16),
                        backgroundColor: AppColors.bg,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : () => _checkIn(provider),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Text('Check-in with ${provider.pet?.petName ?? 'your pet'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}
