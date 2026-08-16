import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/pet_provider.dart';
import '../widgets/bottom_nav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _petNameController = TextEditingController();

  int _step = 0; // 0 = user info, 1 = pet name
  String? _selectedPet; // tracks which pet card is selected

  /// Pet character data: name → asset path.
  static const _petOptions = {
    'Milo': 'images/pets/milo.jpg',
    'Luna': 'images/pets/luna.jpg',
    'Bear': 'images/pets/bear.jpg',
  };

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final name = _userNameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter your name!');
      return;
    }
    if (email.isEmpty) {
      _showSnack('Please enter your email!');
      return;
    }
    setState(() => _step = 1);
  }

  void _selectPet(String name) {
    setState(() {
      _selectedPet = name;
      _petNameController.text = name;
    });
  }

  Future<void> _start(PetProvider provider) async {
    final petName = _petNameController.text.trim();
    if (petName.isEmpty) {
      _showSnack('Give your companion a name first!');
      return;
    }
    await provider.completeOnboarding(
      userName: _userNameController.text.trim(),
      userEmail: _emailController.text.trim(),
      petName: petName,
    );
    if (!mounted) return;
    if (provider.error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      _showSnack(provider.error!);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetProvider>();

    return Scaffold(
      appBar: buildMelloAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _step == 0
                ? _buildUserStep(provider)
                : _buildPetStep(provider),
          ),
        ),
      ),
    );
  }

  // ─── Step 1: User info ──────────────────────────────────────────

  Widget _buildUserStep(PetProvider provider) {
    return Column(
      key: const ValueKey('user_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome!',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          "Let's get to know you first.",
          style: TextStyle(fontSize: 16, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),

        // Hero card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.blueSoft,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  size: 80,
                  color: AppColors.blueDeep,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tell Us About You',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        const Text(
          'Your Name',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _userNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Jane Doe',
            filled: true,
            fillColor: AppColors.mintSoft.withOpacity(0.5),
            prefixIcon:
                const Icon(Icons.person_rounded, color: AppColors.mintDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Your Email',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'e.g. jane@example.com',
            filled: true,
            fillColor: AppColors.mintSoft.withOpacity(0.5),
            prefixIcon:
                const Icon(Icons.email_rounded, color: AppColors.mintDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Step 2: Pick your companion ────────────────────────────────

  Widget _buildPetStep(PetProvider provider) {
    return Column(
      key: const ValueKey('pet_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _step = 0),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Choose Your Companion',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Pick a friend to join your wellness journey!',
            style: TextStyle(fontSize: 16, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 24),

        // Pet selection cards — horizontal row of 3 characters.
        Row(
          children: _petOptions.entries.map((entry) {
            final name = entry.key;
            final asset = entry.value;
            final isSelected = _selectedPet == name;
            final borderColors = {
              'Milo': AppColors.tan,
              'Luna': AppColors.blueDeep,
              'Bear': AppColors.mintDark,
            };

            return Expanded(
              child: GestureDetector(
                onTap: () => _selectPet(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.mintSoft : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (borderColors[name] ?? AppColors.mint)
                          : AppColors.border,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (borderColors[name] ?? AppColors.mint)
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          asset,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.textDark
                              : AppColors.textMuted,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: AppColors.mintDark),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Selected pet hero preview.
        if (_selectedPet != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    _petOptions[_selectedPet]!,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hello, ${_petNameController.text}!',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ],
            ),
          ),

        if (_selectedPet == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.mintSoft,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              children: [
                Icon(Icons.pets_rounded, size: 80, color: AppColors.mintDark),
                SizedBox(height: 16),
                Text(
                  'Tap a friend above!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        const Text(
          'Or type a custom name:',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _petNameController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Name your friend...',
            filled: true,
            fillColor: AppColors.blueSoft.withOpacity(0.5),
            prefixIcon:
                const Icon(Icons.pets_rounded, color: AppColors.blueDeep),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () => _start(provider),
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Start Our Journey'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
