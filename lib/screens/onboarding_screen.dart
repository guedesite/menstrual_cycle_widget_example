import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import '../services/preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  final PreferencesService prefsService;
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.prefsService,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late AnimationController _animController;

  // Configuration du cycle
  int _cycleLength = 28;
  int _periodDuration = 5;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await widget.prefsService.saveConfiguration(
      cycleLength: _cycleLength,
      periodDuration: _periodDuration,
      lastPeriodDate: null,
    );

    // Mettre à jour la configuration du widget
    MenstrualCycleWidget.instance!.updateConfiguration(
      cycleLength: _cycleLength,
      periodDuration: _periodDuration,
      customerId: widget.prefsService.userId,
      defaultLanguage: Languages.english,
    );

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5F0),
              Color(0xFFFFF0F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildCycleConfigPage(),
                  ],
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite,
            size: 120,
            color: Color(0xFFFF6B9D),
          ),
          const SizedBox(height: 40),
          const Text(
            'Bienvenue',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Suivez votre cycle menstruel\nen toute simplicité',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 60),
          _buildFeatureItem(
            Icons.calendar_today,
            'Calendrier complet',
            'Visualisez votre cycle en un coup d\'œil',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.trending_up,
            'Suivi précis',
            'Prédictions basées sur votre rythme',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.lock,
            'Données sécurisées',
            'Vos informations restent privées',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFF6B9D), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleConfigPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Configurez votre cycle',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(height: 40),
          _buildSliderConfig(
            label: 'Durée du cycle',
            value: _cycleLength,
            min: 21,
            max: 35,
            onChanged: (value) {
              setState(() {
                _cycleLength = value.round();
              });
            },
            suffix: 'jours',
          ),
          const SizedBox(height: 40),
          _buildSliderConfig(
            label: 'Durée des règles',
            value: _periodDuration,
            min: 3,
            max: 8,
            onChanged: (value) {
              setState(() {
                _periodDuration = value.round();
              });
            },
            suffix: 'jours',
          ),
        ],
      ),
    );
  }

  Widget _buildSliderConfig({
    required String label,
    required int value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String suffix,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$value $suffix',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFF6B9D),
            inactiveTrackColor: const Color(0xFFFF6B9D).withOpacity(0.2),
            thumbColor: const Color(0xFFFF6B9D),
            overlayColor: const Color(0xFFFF6B9D).withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLastPeriodPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Sélectionnez vos règles',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Utilisez le calendrier pour marquer vos périodes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: constraints.maxHeight - 32,
                    width: double.infinity,
                    child: MenstrualCycleMonthlyCalenderView(
                      themeColor: const Color(0xFFFF6B9D),
                      daySelectedColor: const Color(0xFFFF6B9D),
                      hideInfoView: false,
                      onDataChanged: (value) {
                        setState(() {});
                      },
                      isShowCloseIcon: false,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, color: Color(0xFFFF6B9D)),
                  SizedBox(width: 8),
                  Text(
                    'Précédent',
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 100),
          Row(
            children: List.generate(
              2,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFFFF6B9D)
                      : const Color(0xFFFF6B9D).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage == 1 ? _completeOnboarding : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Suivant',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
