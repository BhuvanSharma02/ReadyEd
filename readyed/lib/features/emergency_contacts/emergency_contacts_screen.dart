import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/emergency_contacts.dart';
import '../../models/indian_states_disasters.dart';

class EmergencyContactsScreen extends StatelessWidget {
  final IndianState state;

  const EmergencyContactsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final nationalContacts = EmergencyContactsData.contactsByState['National'] ?? [];
    final stateContacts = EmergencyContactsData.contactsByState[state.name] ?? [];

    Future<void> launchPhone(String phoneNumber) async {
      final Uri url = Uri(scheme: 'tel', path: phoneNumber);
      if (!await launchUrl(url)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not call $phoneNumber')),
          );
        }
      }
    }

    Widget buildContactList(String title, List<EmergencyContact> contacts) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          if (contacts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('No specific contacts found.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const FaIcon(FontAwesomeIcons.phone, size: 20),
                    title: Text(contact.name),
                    subtitle: Text(contact.number, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    onTap: () => launchPhone(contact.number),
                  ),
                );
              },
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Directory'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildContactList('National Helplines', nationalContacts),
            buildContactList('Helplines for ${state.name}', stateContacts),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
