import 'dart:math' as math;

class IndianState {
  final String name;
  final String code;
  final List<String> commonDisasters;
  final String region;
  final List<double> coordinates; // [latitude, longitude] for center point

  const IndianState({
    required this.name,
    required this.code,
    required this.commonDisasters,
    required this.region,
    required this.coordinates,
  });
}

class DisasterType {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color;
  final int severity; // 1-5 scale

  const DisasterType({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    required this.severity,
  });
}

class IndianStatesData {
  static const List<IndianState> states = [
    // Northern States
    IndianState(
      name: 'Delhi',
      code: 'DL',
      commonDisasters: ['heatwave', 'air_pollution', 'earthquake', 'flood'],
      region: 'North',
      coordinates: [28.6139, 77.2090],
    ),
    IndianState(
      name: 'Jammu and Kashmir',
      code: 'JK',
      commonDisasters: ['earthquake', 'landslide', 'flood', 'avalanche'],
      region: 'North',
      coordinates: [33.7782, 76.5762],
    ),
    IndianState(
      name: 'Punjab',
      code: 'PB',
      commonDisasters: ['flood', 'heatwave', 'drought', 'fog'],
      region: 'North',
      coordinates: [31.1471, 75.3412],
    ),
    IndianState(
      name: 'Haryana',
      code: 'HR',
      commonDisasters: ['drought', 'heatwave', 'flood', 'fog'],
      region: 'North',
      coordinates: [29.0588, 76.0856],
    ),
    IndianState(
      name: 'Himachal Pradesh',
      code: 'HP',
      commonDisasters: ['landslide', 'earthquake', 'flash_flood', 'avalanche'],
      region: 'North',
      coordinates: [31.1048, 77.1734],
    ),
    IndianState(
      name: 'Uttarakhand',
      code: 'UK',
      commonDisasters: ['landslide', 'flash_flood', 'earthquake', 'forest_fire'],
      region: 'North',
      coordinates: [30.0668, 79.0193],
    ),
    IndianState(
      name: 'Uttar Pradesh',
      code: 'UP',
      commonDisasters: ['flood', 'drought', 'heatwave', 'fog'],
      region: 'North',
      coordinates: [26.8467, 80.9462],
    ),
    IndianState(
      name: 'Rajasthan',
      code: 'RJ',
      commonDisasters: ['drought', 'heatwave', 'dust_storm', 'locust_attack'],
      region: 'North',
      coordinates: [27.0238, 74.2179],
    ),
    
    // Eastern States
    IndianState(
      name: 'West Bengal',
      code: 'WB',
      commonDisasters: ['cyclone', 'flood', 'thunderstorm', 'heat_wave'],
      region: 'East',
      coordinates: [22.9868, 87.8550],
    ),
    IndianState(
      name: 'Odisha',
      code: 'OR',
      commonDisasters: ['cyclone', 'flood', 'drought', 'heatwave'],
      region: 'East',
      coordinates: [20.9517, 85.0985],
    ),
    IndianState(
      name: 'Jharkhand',
      code: 'JH',
      commonDisasters: ['drought', 'flood', 'heatwave', 'thunderstorm'],
      region: 'East',
      coordinates: [23.6102, 85.2799],
    ),
    IndianState(
      name: 'Bihar',
      code: 'BR',
      commonDisasters: ['flood', 'drought', 'heatwave', 'thunderstorm'],
      region: 'East',
      coordinates: [25.0961, 85.3131],
    ),
    
    // Western States
    IndianState(
      name: 'Maharashtra',
      code: 'MH',
      commonDisasters: ['drought', 'flood', 'cyclone', 'landslide'],
      region: 'West',
      coordinates: [19.7515, 75.7139],
    ),
    IndianState(
      name: 'Gujarat',
      code: 'GJ',
      commonDisasters: ['drought', 'cyclone', 'earthquake', 'flood'],
      region: 'West',
      coordinates: [23.0225, 72.5714],
    ),
    IndianState(
      name: 'Goa',
      code: 'GA',
      commonDisasters: ['monsoon_flooding', 'coastal_erosion', 'thunderstorm'],
      region: 'West',
      coordinates: [15.2993, 74.1240],
    ),
    
    // Southern States
    IndianState(
      name: 'Karnataka',
      code: 'KA',
      commonDisasters: ['drought', 'flood', 'landslide', 'heatwave'],
      region: 'South',
      coordinates: [15.3173, 75.7139],
    ),
    IndianState(
      name: 'Kerala',
      code: 'KL',
      commonDisasters: ['flood', 'landslide', 'coastal_erosion', 'thunderstorm'],
      region: 'South',
      coordinates: [10.8505, 76.2711],
    ),
    IndianState(
      name: 'Tamil Nadu',
      code: 'TN',
      commonDisasters: ['cyclone', 'drought', 'flood', 'tsunami'],
      region: 'South',
      coordinates: [11.1271, 78.6569],
    ),
    IndianState(
      name: 'Andhra Pradesh',
      code: 'AP',
      commonDisasters: ['cyclone', 'drought', 'flood', 'heatwave'],
      region: 'South',
      coordinates: [15.9129, 79.7400],
    ),
    IndianState(
      name: 'Telangana',
      code: 'TS',
      commonDisasters: ['drought', 'flood', 'heatwave', 'thunderstorm'],
      region: 'South',
      coordinates: [18.1124, 79.0193],
    ),
    
    // Central States
    IndianState(
      name: 'Madhya Pradesh',
      code: 'MP',
      commonDisasters: ['drought', 'flood', 'heatwave', 'thunderstorm'],
      region: 'Central',
      coordinates: [22.9734, 78.6569],
    ),
    IndianState(
      name: 'Chhattisgarh',
      code: 'CG',
      commonDisasters: ['drought', 'flood', 'thunderstorm', 'hailstorm'],
      region: 'Central',
      coordinates: [21.2787, 81.8661],
    ),
    
    // Northeastern States
    IndianState(
      name: 'Assam',
      code: 'AS',
      commonDisasters: ['flood', 'landslide', 'earthquake', 'thunderstorm'],
      region: 'Northeast',
      coordinates: [26.2006, 92.9376],
    ),
    IndianState(
      name: 'Arunachal Pradesh',
      code: 'AR',
      commonDisasters: ['landslide', 'earthquake', 'flash_flood', 'forest_fire'],
      region: 'Northeast',
      coordinates: [28.2180, 94.7278],
    ),
    IndianState(
      name: 'Manipur',
      code: 'MN',
      commonDisasters: ['earthquake', 'landslide', 'flood', 'drought'],
      region: 'Northeast',
      coordinates: [24.6637, 93.9063],
    ),
    IndianState(
      name: 'Meghalaya',
      code: 'ML',
      commonDisasters: ['landslide', 'flood', 'earthquake', 'hailstorm'],
      region: 'Northeast',
      coordinates: [25.4670, 91.3662],
    ),
    IndianState(
      name: 'Mizoram',
      code: 'MZ',
      commonDisasters: ['landslide', 'earthquake', 'flash_flood', 'cyclone'],
      region: 'Northeast',
      coordinates: [23.1645, 92.9376],
    ),
    IndianState(
      name: 'Nagaland',
      code: 'NL',
      commonDisasters: ['landslide', 'earthquake', 'flood', 'drought'],
      region: 'Northeast',
      coordinates: [26.1584, 94.5624],
    ),
    IndianState(
      name: 'Sikkim',
      code: 'SK',
      commonDisasters: ['landslide', 'earthquake', 'flash_flood', 'avalanche'],
      region: 'Northeast',
      coordinates: [27.5330, 88.5122],
    ),
    IndianState(
      name: 'Tripura',
      code: 'TR',
      commonDisasters: ['flood', 'landslide', 'cyclone', 'drought'],
      region: 'Northeast',
      coordinates: [23.9408, 91.9882],
    ),
  ];

  static const Map<String, DisasterType> disasterTypes = {
    'cyclone': DisasterType(
      id: 'cyclone',
      name: 'Cyclone',
      description: 'Severe tropical storms with strong winds and heavy rain',
      iconName: 'hurricane',
      color: '0xFF1565C0',
      severity: 5,
    ),
    'flood': DisasterType(
      id: 'flood',
      name: 'Flood',
      description: 'Overflow of water that submerges land',
      iconName: 'house-flood-water',
      color: '0xFF0277BD',
      severity: 4,
    ),
    'drought': DisasterType(
      id: 'drought',
      name: 'Drought',
      description: 'Prolonged period of abnormally low rainfall',
      iconName: 'sun',
      color: '0xFFFF8F00',
      severity: 3,
    ),
    'earthquake': DisasterType(
      id: 'earthquake',
      name: 'Earthquake',
      description: 'Sudden shaking of the ground',
      iconName: 'house-chimney-crack',
      color: '0xFF5D4037',
      severity: 5,
    ),
    'landslide': DisasterType(
      id: 'landslide',
      name: 'Landslide',
      description: 'Movement of rock, earth, or debris down a slope',
      iconName: 'mountain',
      color: '0xFF795548',
      severity: 4,
    ),
    'heatwave': DisasterType(
      id: 'heatwave',
      name: 'Heat Wave',
      description: 'Period of excessively hot weather',
      iconName: 'temperature-high',
      color: '0xFFE65100',
      severity: 3,
    ),
    'thunderstorm': DisasterType(
      id: 'thunderstorm',
      name: 'Thunderstorm',
      description: 'Storm with thunder, lightning, and heavy rain',
      iconName: 'cloud-bolt',
      color: '0xFF424242',
      severity: 2,
    ),
    'forest_fire': DisasterType(
      id: 'forest_fire',
      name: 'Forest Fire',
      description: 'Uncontrolled fire in forested areas',
      iconName: 'fire',
      color: '0xFFD32F2F',
      severity: 4,
    ),
    'tsunami': DisasterType(
      id: 'tsunami',
      name: 'Tsunami',
      description: 'Series of ocean waves with very long wavelengths',
      iconName: 'water',
      color: '0xFF0288D1',
      severity: 5,
    ),
    'avalanche': DisasterType(
      id: 'avalanche',
      name: 'Avalanche',
      description: 'Rapid flow of snow down a slope',
      iconName: 'snowflake',
      color: '0xFF81C784',
      severity: 4,
    ),
    'air_pollution': DisasterType(
      id: 'air_pollution',
      name: 'Air Pollution',
      description: 'Harmful substances in the atmosphere',
      iconName: 'smog',
      color: '0xFF757575',
      severity: 2,
    ),
    'dust_storm': DisasterType(
      id: 'dust_storm',
      name: 'Dust Storm',
      description: 'Strong wind carrying large amounts of dust',
      iconName: 'wind',
      color: '0xFFA1887F',
      severity: 2,
    ),
    'fog': DisasterType(
      id: 'fog',
      name: 'Dense Fog',
      description: 'Thick cloud of water droplets near ground level',
      iconName: 'cloud',
      color: '0xFF90A4AE',
      severity: 1,
    ),
    'hailstorm': DisasterType(
      id: 'hailstorm',
      name: 'Hailstorm',
      description: 'Storm producing balls of ice',
      iconName: 'cloud-hail',
      color: '0xFF546E7A',
      severity: 2,
    ),
    'flash_flood': DisasterType(
      id: 'flash_flood',
      name: 'Flash Flood',
      description: 'Sudden flooding of low-lying areas',
      iconName: 'house-flood-water-circle-arrow-right',
      color: '0xFF1976D2',
      severity: 4,
    ),
    'locust_attack': DisasterType(
      id: 'locust_attack',
      name: 'Locust Attack',
      description: 'Swarms of locusts destroying crops',
      iconName: 'bug',
      color: '0xFF689F38',
      severity: 2,
    ),
    'coastal_erosion': DisasterType(
      id: 'coastal_erosion',
      name: 'Coastal Erosion',
      description: 'Loss of coastal land due to wave action',
      iconName: 'water',
      color: '0xFF0097A7',
      severity: 2,
    ),
    'monsoon_flooding': DisasterType(
      id: 'monsoon_flooding',
      name: 'Monsoon Flooding',
      description: 'Flooding during monsoon season',
      iconName: 'cloud-rain',
      color: '0xFF00796B',
      severity: 3,
    ),
  };

  static IndianState? getStateByName(String name) {
    try {
      return states.firstWhere(
        (state) => state.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static IndianState? getStateByCode(String code) {
    try {
      return states.firstWhere(
        (state) => state.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<IndianState> getStatesByRegion(String region) {
    return states.where(
      (state) => state.region.toLowerCase() == region.toLowerCase(),
    ).toList();
  }

  static List<DisasterType> getDisastersForState(String stateName) {
    final state = getStateByName(stateName);
    if (state == null) return [];
    
    return state.commonDisasters
        .map((disasterId) => disasterTypes[disasterId])
        .where((disaster) => disaster != null)
        .cast<DisasterType>()
        .toList();
  }

  static IndianState? findNearestState(double latitude, double longitude) {
    IndianState? nearest;
    double minDistance = double.infinity;

    for (final state in states) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        state.coordinates[0],
        state.coordinates[1],
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearest = state;
      }
    }

    return nearest;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radiusOfEarth = 6371; // Earth's radius in km
    
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return radiusOfEarth * c;
  }

  static double _degToRad(double deg) {
    return deg * (math.pi / 180);
  }
}
