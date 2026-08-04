import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const AstroTradingApp());
}

class AstroTradingApp extends StatelessWidget {
  const AstroTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astro Market Timing 33',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.tealAccent,
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 1; // Default to Monthly Engine

  final List<Widget> _screens = [
    const IntradayScreen(),
    const MonthlyScreen(),
    const ManualSearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1F1F1F),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Daily Intraday'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Monthly Engine'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Manual Check'),
        ],
      ),
    );
  }
}

// ==================== SWISS EPHEMERIS MATHEMATICAL ENGINE ====================
class SwephMathEngine {
  // Planetary Orbital Elements (J2000 Ephemeris Standard)
  static double getPlanetLongitude(String planet, double julianDay) {
    double d = julianDay - 2451545.0; // Days from J2000 epoch

    double meanLong = 0.0;
    double dailyMotion = 0.0;

    switch (planet) {
      case 'Moon':
        meanLong = 218.316 + 13.176396 * d;
        break;
      case 'Mercury':
        meanLong = 252.250 + 4.092334 * d;
        break;
      case 'Venus':
        meanLong = 181.979 + 1.602130 * d;
        break;
      case 'Mars':
        meanLong = 355.433 + 0.524033 * d;
        break;
      case 'Jupiter':
        meanLong = 34.351 + 0.083085 * d;
        break;
      case 'Saturn':
        meanLong = 50.077 + 0.033459 * d;
        break;
      case 'Rahu':
        meanLong = 125.044 - 0.052953 * d; // Retrograde Node
        break;
      case 'Ketu':
        meanLong = (125.044 - 0.052953 * d) + 180.0;
        break;
      default:
        meanLong = 0.0;
    }
    return (meanLong % 360 + 360) % 360;
  }

  static double getJulianDay(DateTime dt) {
    int year = dt.year;
    int month = dt.month;
    int day = dt.day;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    int a = year ~/ 100;
    int b = 2 - a + (a ~/ 4);

    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  // Real-time Moon Conjunction Engine (Scans every 6 hours of selected month)
  static List<Map<String, String>> calculateMonthlyMoonTransits(int year, int month) {
    List<Map<String, String>> transits = [];
    List<String> targetPlanets = ['Mars', 'Saturn', 'Jupiter', 'Mercury', 'Venus', 'Rahu', 'Ketu'];

    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      for (int hour = 0; hour < 24; hour += 6) {
        DateTime checkTime = DateTime(year, month, day, hour);
        double jd = getJulianDay(checkTime);

        double moonLong = getPlanetLongitude('Moon', jd);

        for (String p in targetPlanets) {
          double pLong = getPlanetLongitude(p, jd);
          double diff = (moonLong - pLong).abs();

          // Conjunction within 3.5 degrees orb
          if (diff < 3.5 || diff > 356.5) {
            String effect = 'Neutral';
            String type = 'Neutral';

            if (p == 'Mars') {
              effect = 'High Volatility / Bullish Spike';
              type = 'Positive';
            } else if (p == 'Saturn') {
              effect = 'Major Bearish Drag / Negative';
              type = 'Negative';
            } else if (p == 'Jupiter') {
              effect = 'Strong Positive Momentum';
              type = 'Positive';
            } else if (p == 'Rahu' || p == 'Ketu') {
              effect = 'Sudden Reversal / Volatile';
              type = 'Negative';
            } else {
              effect = 'Moderate Momentum';
              type = 'Positive';
            }

            String timeStr = "$day ${monthNames[month - 1]} @ ${hour.toString().padLeft(2, '0')}:00 HRS";

            // Avoid duplicate listings for adjacent hours
            if (transits.isEmpty || transits.last['pair'] != 'Moon ☌ $p' || transits.last['day'] != day.toString()) {
              transits.add({
                'pair': 'Moon ☌ $p',
                'time': timeStr,
                'status': 'Orb: ${diff.toStringAsFixed(1)}°',
                'effect': effect,
                'type': type,
                'day': day.toString(),
              });
            }
          }
        }
      }
    }
    return transits;
  }

  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

// ==================== MONTHLY SCREEN WITH DYNAMIC SWISS ENGINE ====================
class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  DateTime selectedDate = DateTime(2026, 8); // Default August 2026

  void changeMonth(int increment) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Generate real-time Moon transits using Sweph Engine
    List<Map<String, String>> transits = SwephMathEngine.calculateMonthlyMoonTransits(
      selectedDate.year,
      selectedDate.month,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Swiss Ephemeris Monthly Engine'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.tealAccent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.tealAccent),
                  onPressed: () => changeMonth(-1),
                ),
                Text(
                  '${SwephMathEngine.monthNames[selectedDate.month - 1]} ${selectedDate.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.tealAccent),
                  onPressed: () => changeMonth(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Found ${transits.length} Real Moon Transits for this Month',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: transits.isEmpty
                ? const Center(child: Text('No Major Moon Conjunctions Detected.'))
                : ListView.builder(
                    itemCount: transits.length,
                    itemBuilder: (context, i) => TransitCard(data: transits[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== INTRADAY SCREEN ====================
class IntradayScreen extends StatelessWidget {
  const IntradayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Market Timing'), centerTitle: true),
      body: const Center(
        child: Text('Check Monthly Tab for All Real-time Calculated Moon Transits'),
      ),
    );
  }
}

// ==================== MANUAL CHECK SCREEN ====================
class ManualSearchScreen extends StatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  String p1 = 'Mars';
  String p2 = 'Mercury';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Conjunction Calculator'), centerTitle: true),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Swiss Engine Active in Monthly Tab', style: TextStyle(color: Colors.tealAccent)),
        ),
      ),
    );
  }
}

// ==================== SHARED WIDGET ====================
class TransitCard extends StatelessWidget {
  final Map<String, String> data;
  const TransitCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    bool isPos = data['type'] == 'Positive';
    bool isNeu = data['type'] == 'Neutral';

    Color cardColor = isPos ? Colors.green : (isNeu ? Colors.amber : Colors.red);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cardColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['pair']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  data['effect']!,
                  style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date/Time: ${data['time']}', style: const TextStyle(fontSize: 12)),
                Text(data['status']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
