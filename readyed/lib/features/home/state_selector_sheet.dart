import 'package:flutter/material.dart';
import '../../models/indian_states_disasters.dart';

class StateSelectorSheet extends StatelessWidget {
  final Function(IndianState) onStateSelected;

  const StateSelectorSheet({super.key, required this.onStateSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Text(
                'Select Your State',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: IndianStatesData.states.length,
                  itemBuilder: (context, index) {
                    final state = IndianStatesData.states[index];
                    return ListTile(
                      title: Text(state.name),
                      subtitle: Text('${state.region} India'),
                      onTap: () {
                        onStateSelected(state);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}