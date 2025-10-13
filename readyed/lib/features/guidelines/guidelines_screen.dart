import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class GuidelinesScreen extends StatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  State<GuidelinesScreen> createState() => _GuidelinesScreenState();
}

class _GuidelinesScreenState extends State<GuidelinesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Guidelines'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 20),
              text: 'Before',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.triangleExclamation, size: 20),
              text: 'During',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.handshake, size: 20),
              text: 'After',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.listCheck,
                  color: Colors.orange.shade700,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Safety Guidelines',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essential safety procedures for before, during, and after disasters.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBeforeTab(),
                _buildDuringTab(),
                _buildAfterTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidelineSection(
            'Emergency Kit Checklist',
            FontAwesomeIcons.suitcase,
            Colors.blue,
            [
              'Water (1 gallon per person per day for 3 days)',
              'Non-perishable food (3-day supply per person)',
              'Battery-powered or hand crank radio',
              'Flashlight and extra batteries',
              'First aid kit and medications',
              'Whistle for signaling help',
              'Dust masks and plastic sheeting',
              'Moist towelettes and garbage bags',
              'Wrench or pliers to turn off utilities',
              'Cell phone with chargers and backup battery'
            ],
          ),
          
          _buildGuidelineSection(
            'Communication Plan',
            FontAwesomeIcons.phoneFlip,
            Colors.green,
            [
              'Choose an out-of-state contact person',
              'Make sure all family members know the contact info',
              'Decide on meeting places (home, neighborhood, city)',
              'Keep important documents in a waterproof container',
              'Take photos of important documents and store digitally',
              'Know how to turn off utilities (gas, water, electricity)'
            ],
          ),
          
          _buildGuidelineSection(
            'Home Preparation',
            FontAwesomeIcons.house,
            Colors.purple,
            [
              'Secure heavy furniture and appliances to walls',
              'Install safety latches on cabinets',
              'Know safe spots in each room',
              'Practice evacuation routes',
              'Keep trees and shrubs trimmed',
              'Review insurance policies annually'
            ],
          ),
          
          _buildEmergencyContactCard(),
        ],
      ),
    );
  }

  Widget _buildDuringTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidelineSection(
            'General Safety Rules',
            FontAwesomeIcons.shield,
            Colors.red,
            [
              'Stay calm and don\'t panic',
              'Follow your emergency plan',
              'Listen to emergency broadcasts',
              'Stay away from damaged areas',
              'Help injured people if you can do so safely',
              'Stay together as a family if possible'
            ],
          ),
          
          _buildDisasterSpecificCard('Earthquake', FontAwesomeIcons.houseChimneyCrack, Colors.brown, [
            'Drop, Cover, and Hold On',
            'Stay away from windows and heavy objects',
            'If outside, move away from buildings and power lines',
            'If in a car, stop and stay inside'
          ]),
          
          _buildDisasterSpecificCard('Fire', FontAwesomeIcons.fire, Colors.red, [
            'Get low and crawl under smoke',
            'Feel doors before opening them',
            'Use stairs, never elevators',
            'Stop, drop, and roll if clothes catch fire'
          ]),
          
          _buildDisasterSpecificCard('Flood', FontAwesomeIcons.houseFloodWater, Colors.blue, [
            'Get to higher ground immediately',
            'Never walk or drive through flood water',
            'Avoid moving water - just 6 inches can knock you down',
            'Stay away from downed power lines'
          ]),
          
          _buildDisasterSpecificCard('Hurricane', FontAwesomeIcons.hurricane, Colors.indigo, [
            'Stay indoors and away from windows',
            'Go to the lowest floor and interior room',
            'Don\'t go outside during the eye of the storm',
            'Beware of flying debris'
          ]),
        ],
      ),
    );
  }

  Widget _buildAfterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidelineSection(
            'Immediate Safety Steps',
            FontAwesomeIcons.handHoldingHeart,
            Colors.green,
            [
              'Check for injuries and give first aid',
              'Check for hazards like gas leaks or electrical damage',
              'Use flashlights, not candles',
              'Stay out of damaged buildings',
              'Listen to emergency broadcasts for information',
              'Help neighbors who may need assistance'
            ],
          ),
          
          _buildGuidelineSection(
            'Damage Assessment',
            FontAwesomeIcons.magnifyingGlass,
            Colors.orange,
            [
              'Take photos of damage for insurance',
              'Check utilities but don\'t turn them on if damaged',
              'Watch for loose power lines and report them',
              'Be aware of new hazards created by the disaster',
              'Don\'t enter damaged buildings',
              'Watch for animals that may have been displaced'
            ],
          ),
          
          _buildGuidelineSection(
            'Recovery and Cleanup',
            FontAwesomeIcons.broom,
            Colors.blue,
            [
              'Wait for authorities to say it\'s safe',
              'Contact insurance company to report damage',
              'Keep receipts for expenses related to the disaster',
              'Be careful with cleanup - wear protective gear',
              'Throw away contaminated food and water',
              'Document all conversations with officials'
            ],
          ),
          
          _buildGuidelineSection(
            'Emotional Recovery',
            FontAwesomeIcons.heart,
            Colors.pink,
            [
              'Talk about the experience with family and friends',
              'Maintain normal routines when possible',
              'Take care of yourself - eat well, sleep, exercise',
              'Seek professional help if feeling overwhelmed',
              'Be patient - recovery takes time',
              'Help others in your community when you can'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineSection(String title, IconData icon, Color color, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => ChecklistItem(text: item, color: color)).toList(),
        ],
      ),
    );
  }

  Widget _buildDisasterSpecificCard(String title, IconData icon, Color color, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color)),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.phone,
                color: Colors.red.shade700,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                'Emergency Contacts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactRow('Emergency Services', '911'),
          _buildContactRow('Poison Control', '1-800-222-1222'),
          _buildContactRow('Red Cross', '1-800-733-2767'),
          const SizedBox(height: 12),
          Text(
            'Add your local emergency numbers and out-of-state contact information.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            number,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistItem extends StatefulWidget {
  final String text;
  final Color color;

  const ChecklistItem({super.key, required this.text, required this.color});

  @override
  State<ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => isChecked = !isChecked),
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              child: Icon(
                isChecked ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circle,
                color: isChecked ? widget.color : Colors.grey.shade400,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isChecked = !isChecked),
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked ? Colors.grey.shade600 : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}