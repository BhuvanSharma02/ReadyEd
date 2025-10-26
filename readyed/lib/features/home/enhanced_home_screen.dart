import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../../models/indian_states_disasters.dart';
import '../../models/user_model.dart';
import '../../widgets/disaster_category_card.dart';
import '../../widgets/quick_stats_card.dart';
import '../drills/drill_detail_screen.dart';
import '../content/disaster_detail_screen.dart';
import 'state_selector_sheet.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  bool _isLocationLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadUserData();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLocationLoading = true);
    
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    try {
      // Try to detect current state
      await locationService.detectCurrentState();
    } catch (e) {
      print('Location detection failed: $e');
    }
    
    if (mounted) {
      setState(() => _isLocationLoading = false);
    }
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getUserData();
    if (mounted) {
      setState(() => _currentUser = userData);
    }
  }

  Future<void> _refreshLocation() async {
    setState(() => _isLocationLoading = true);
    
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    try {
      await locationService.detectCurrentState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location updated: ${locationService.currentState?.name ?? "Unknown"}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to detect location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    if (mounted) {
      setState(() => _isLocationLoading = false);
    }
  }

  void _showStateSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StateSelectorSheet(
        onStateSelected: (state) {
          final locationService = Provider.of<LocationService>(context, listen: false);
          locationService.setManualState(state);
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final currentState = locationService.currentState;
    final stateDisasters = locationService.getCurrentStateDisasters();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshLocation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info and location
                _buildHeader(currentState),
                const SizedBox(height: 24),

                // Quick Stats
                if (_currentUser != null) _buildQuickStats(),

                const SizedBox(height: 24),

                // Location-based disasters
                if (stateDisasters.isNotEmpty) ...[
                  _buildLocationBasedSection(currentState!, stateDisasters),
                  const SizedBox(height: 32),
                ],

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 32),

                // Emergency Alert (if any)
                _buildEmergencyAlert(),
                const SizedBox(height: 32),

                // Emergency Contact Card
                _buildEmergencyContact(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(IndianState? currentState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User greeting and app title
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.shieldHeart,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ReadyEd',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_currentUser != null)
                      Text(
                        'Hello, ${_currentUser!.name}!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _refreshLocation,
                icon: _isLocationLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(FontAwesomeIcons.locationCrosshairs, color: Colors.white),
                tooltip: 'Refresh Location',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location info
          GestureDetector(
            onTap: _showStateSelector,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.mapLocationDot,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentState != null 
                          ? '${currentState.name}, ${currentState.region} India'
                          : 'Tap to select your state',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    FontAwesomeIcons.chevronDown,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Animated tagline
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Stay Safe, Stay Prepared!',
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: QuickStatsCard(
            title: 'Level ${_currentUser!.getLevel()}',
            value: '${_currentUser!.totalScore} pts',
            icon: FontAwesomeIcons.trophy,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickStatsCard(
            title: '${_currentUser!.streak} Day',
            value: 'Streak',
            icon: FontAwesomeIcons.fire,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickStatsCard(
            title: '${_currentUser!.getTotalDrillsCompleted()}',
            value: 'Drills Done',
            icon: FontAwesomeIcons.userShield,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBasedSection(IndianState state, List<DisasterType> disasters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              FontAwesomeIcons.mapLocationDot,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Common in ${state.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Disasters most likely to occur in your area',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: disasters.take(6).length,
            itemBuilder: (context, index) {
              final disaster = disasters[index];
              return Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(right: 12),
                child: DisasterCategoryCard(
                  title: disaster.name,
                  icon: _getIconData(disaster.iconName),
                  color: Color(int.parse(disaster.color)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisasterDetailScreen(disasterType: disaster.id),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Practice Drill',
                'Interactive safety simulations',
                FontAwesomeIcons.userShield,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrillDetailScreen(drillType: 'earthquake'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Emergency Kit',
                'Check your preparedness',
                FontAwesomeIcons.suitcase,
                Colors.blue,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emergency kit checklist coming soon!')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, 
                         Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.amber.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Alert',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
                Text(
                  'Monitor local weather updates and emergency broadcasts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.amber.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.phone,
            color: Colors.red.shade700,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Contact',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  'In case of real emergency, call 112 (National Emergency)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'hurricane': return FontAwesomeIcons.hurricane;
      case 'house-flood-water': return FontAwesomeIcons.houseFloodWater;
      case 'sun': return FontAwesomeIcons.sun;
      case 'house-chimney-crack': return FontAwesomeIcons.houseChimneyCrack;
      case 'mountain': return FontAwesomeIcons.mountain;
      case 'temperature-high': return FontAwesomeIcons.temperatureHigh;
      case 'cloud-bolt': return FontAwesomeIcons.cloudBolt;
      case 'fire': return FontAwesomeIcons.fire;
      case 'water': return FontAwesomeIcons.water;
      case 'snowflake': return FontAwesomeIcons.snowflake;
      case 'smog': return FontAwesomeIcons.smog;
      case 'wind': return FontAwesomeIcons.wind;
      case 'cloud': return FontAwesomeIcons.cloud;
      case 'cloud-hail': return FontAwesomeIcons.cloudShowersHeavy;
      case 'bug': return FontAwesomeIcons.bug;
      case 'cloud-rain': return FontAwesomeIcons.cloudRain;
      default: return FontAwesomeIcons.triangleExclamation;
    }
  }
}