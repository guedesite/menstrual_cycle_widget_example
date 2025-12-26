import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import '../services/preferences_service.dart';
import '../model/menstrual_summary.dart';

class CalendarScreen extends StatefulWidget {
  final PreferencesService prefsService;
  final VoidCallback? onFinalize;

  const CalendarScreen({
    super.key,
    required this.prefsService,
    this.onFinalize,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  final instance = MenstrualCycleWidget.instance!;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  MenstrualCycleSummaryData? _summaryData;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    _animController.forward();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    try {
      Map<String, dynamic> summaryData = await instance.getMenstrualCycleSummary();
      if (summaryData.isNotEmpty && mounted) {
        setState(() {
          _summaryData = MenstrualCycleSummaryData.fromJson(summaryData);
        });
      }
    } catch (e) {
      // Erreur lors du chargement des données
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
              Color(0xFFFFFAFC),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildCalendarView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final bool isFromOnboarding = widget.onFinalize != null;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!isFromOnboarding)
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFFFF6B9D),
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              else
                const SizedBox(width: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Calendrier Complet',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B9D),
                  ),
                ),
              ),
              if (isFromOnboarding)
                ElevatedButton.icon(
                  onPressed: widget.onFinalize,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Finaliser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(left: 48),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B9D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFF6B9D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cliquez sur "Edit Period Dates" pour organiser votre timeline',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: MenstrualCycleMonthlyCalenderView(
        themeColor: const Color(0xFFFF6B9D),
        daySelectedColor: const Color(0xFFFF6B9D),
        hideInfoView: false,
        onDataChanged: (value) {
          setState(() {});
          _loadSummaryData();
        },
        isShowCloseIcon: false,
      ),
    );
  }
}
