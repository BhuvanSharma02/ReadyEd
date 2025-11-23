class EmergencyContact {
  final String name;
  final String number;

  const EmergencyContact({required this.name, required this.number});
}

class EmergencyContactsData {
  static const Map<String, List<EmergencyContact>> contactsByState = {
    'National': [
      EmergencyContact(name: 'National Emergency Number', number: '112'),
      EmergencyContact(name: 'NDMA Helpline', number: '1078'),
      EmergencyContact(name: 'NDRF Helpline', number: '011-26701728'),
    ],
    'Andhra Pradesh': [
      EmergencyContact(name: 'State Control Room', number: '0863-2345122'),
    ],
    'Arunachal Pradesh': [
      EmergencyContact(name: 'State Control Room', number: '0360-2212948'),
      EmergencyContact(name: 'Helpline', number: '8257891310'),
    ],
    'Assam': [
      EmergencyContact(name: 'State Emergency Operation Center', number: '1079'),
      EmergencyContact(name: 'State Control Room', number: '0361-2237219'),
    ],
    'Bihar': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
      EmergencyContact(name: 'Landline', number: '0612-2217305'),
    ],
    'Chhattisgarh': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
       EmergencyContact(name: 'Landline', number: '0771-2221433'),
    ],
    'Goa': [
      EmergencyContact(name: 'State Control Room', number: '0832-2419550'),
    ],
    'Gujarat': [
      EmergencyContact(name: 'State Emergency Operation Center', number: '1077'),
    ],
    'Haryana': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Himachal Pradesh': [
      EmergencyContact(name: 'State Emergency Operation Center', number: '1077'),
    ],
    'Jammu and Kashmir': [
      EmergencyContact(name: 'Srinagar Control Room', number: '0194-2452138'),
      EmergencyContact(name: 'Jammu Control Room', number: '0191-2542000'),
    ],
    'Jharkhand': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Karnataka': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Kerala': [
      EmergencyContact(name: 'State Emergency Operation Center', number: '1079'),
    ],
    'Ladakh': [
      EmergencyContact(name: 'State Control Room', number: '01982-260887'),
    ],
    'Lakshadweep': [
      EmergencyContact(name: 'District Control Room', number: '1077'),
    ],
    'Madhya Pradesh': [
      EmergencyContact(name: 'State Situation Room', number: '1079'),
    ],
    'Maharashtra': [
      EmergencyContact(name: 'State Control Room', number: '022-22027990'),
    ],
    'Manipur': [
      EmergencyContact(name: 'State Control Room', number: '0385-2443441'),
    ],
    'Meghalaya': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Mizoram': [
      EmergencyContact(name: 'State Control Room', number: '1077'),
    ],
    'Nagaland': [
      EmergencyContact(name: 'State Control Room', number: '1077'),
    ],
     'NCT of Delhi': [
      EmergencyContact(name: 'Delhi Disaster Management', number: '1077'),
    ],
    'Delhi': [
      EmergencyContact(name: 'Delhi Disaster Management', number: '1077'),
    ],
    'Odisha': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Puducherry': [
      EmergencyContact(name: 'Emergency Operation Center', number: '1079'),
    ],
    'Punjab': [
      EmergencyContact(name: 'District Control Room', number: '1077'),
    ],
    'Rajasthan': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Sikkim': [
      EmergencyContact(name: 'State Control Room', number: '1077'),
    ],
    'Tamil Nadu': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Telangana': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Tripura': [
      EmergencyContact(name: 'State Control Room', number: '1077'),
    ],
    'Uttarakhand': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'Uttar Pradesh': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
    'West Bengal': [
      EmergencyContact(name: 'State Control Room', number: '1070'),
    ],
     'Andaman and Nicobar Islands': [
      EmergencyContact(name: 'Emergency Operation Center', number: '1077'),
    ],
    'Chandigarh': [
      EmergencyContact(name: 'Emergency Operation Center', number: '1077'),
    ],
    'Dadra and Nagar Haveli and Daman and Diu': [
      EmergencyContact(name: 'Control Room', number: '1077'),
    ],
  };
}
