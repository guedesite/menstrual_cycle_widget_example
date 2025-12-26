import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';

class HormoneGraphScreen extends StatefulWidget {
  const HormoneGraphScreen({super.key});

  @override
  State<HormoneGraphScreen> createState() => _HormoneGraphScreenState();
}

class _HormoneGraphScreenState extends State<HormoneGraphScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

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
                  child: _buildGraphView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFF6B9D),
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Graphique Hormonal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B9D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildGraphCard(),
            const SizedBox(height: 24),
            _buildLegend(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5F0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFFFF6B9D),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Les niveaux d\'estrogène et de progestérone varient tout au long du cycle menstruel.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Niveaux Hormonaux',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: EstrogenProgesteroneGraph(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Légende',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegendItem(
            color: Colors.blue,
            title: 'Estrogène',
            description:
                'L\'estrogène augmente avant l\'ovulation pour préparer l\'organisme à une éventuelle grossesse.',
          ),
          const SizedBox(height: 12),
          _buildLegendItem(
            color: Colors.orange,
            title: 'Progestérone',
            description:
                'La progestérone augmente après l\'ovulation pour maintenir la muqueuse utérine.',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
