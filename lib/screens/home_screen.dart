import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import '../services/preferences_service.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'hormone_graph_screen.dart';

class HomeScreen extends StatefulWidget {
  final PreferencesService prefsService;

  const HomeScreen({super.key, required this.prefsService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final instance = MenstrualCycleWidget.instance!;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
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
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildCycleView(),
                              const SizedBox(height: 30),
                              _buildQuickActions(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mon Cycle',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B9D),
                ),
              ),
              Text(
                'Cycle de ${widget.prefsService.cycleLength} jours',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFFF6B9D), size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    prefsService: widget.prefsService,
                  ),
                ),
              );
              if (result == true && mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCycleView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
      child: AbsorbPointer(
        child: MenstrualCyclePhaseView(
          key: ValueKey('${widget.prefsService.cycleLength}_${widget.prefsService.periodDuration}'),
          size: MediaQuery.of(context).size.width - 80,
          theme: MenstrualCycleTheme.arcs,
          isRemoveBackgroundPhaseColor: false,
          spaceBtnTitleMessage: 5,
          centralCircleSize: 120,
          centralCircleBackgroundColor: const Color(0xFFFFE5F0),
          viewType: MenstrualCycleViewType.circleText,
          isAutoSetData: true,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.calendar_month,
                  title: 'Calendrier',
                  color: const Color(0xFFFF6B9D),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarScreen(
                          prefsService: widget.prefsService,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.show_chart,
                  title: 'Hormones',
                  color: const Color(0xFFFF6B9D),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HormoneGraphScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
