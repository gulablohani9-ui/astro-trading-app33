import 'package:flutter/material.dart';

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
  int _currentIndex = 0;

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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Monthly All Transits'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Manual Check'),
        ],
      ),
    );
  }
}

// ==================== SWISS EPHEMERIS MATHEMATICAL ENGINE ====================
class SwephEngine {
  static double getPlanetLongitude(String planet, double julianDay) {
    double d = julianDay - 2451545.0; // Days from epoch J2000

    double meanLong = 0.0;
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
        meanLong = 125.044 - 0.052953 * d;
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
    double hourFraction = (dt.hour + dt.minute / 60.0) / 24.0;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    int a = year ~/ 100;
    int b = 2 - a + (a ~/ 4);

    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day + hourFraction +
        b -
        1524.5;
  }

  // Calculate ALL PLANET Conjunctions for Selected Month
  static List<Map<String, String>> calculateMonthlyAllTransits(int year, int month) {
    List<Map<String, String>> transits = [];
    List<String> allPlanets = ['Moon', 'Mars', 'Mercury', 'Venus', 'Jupiter', 'Saturn', 'Rahu', 'Ketu'];

    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime checkTime = DateTime(year, month, day, 12, 0); // Noon scan
      double jd = getJulianDay(checkTime);

      for (int i = 0; i < allPlanets.length; i++) {
        for (int j = i + 1; j < allPlanets.length; j++) {
          String p1 = allPlanets[i];
          String p2 = allPlanets[j];

          if (p1 == 'Rahu' && p2 == 'Ketu') continue; // Opposite nodes

          double l1 = getPlanetLongitude(p1, jd);
          double l2 = getPlanetLongitude(p2, jd);
          double diff = (l1 - l2).abs();

          // Orb range within 6.0 degrees
          if (diff < 6.0 || diff > 354.0) {
            double exactOrb = diff > 180 ? (360 - diff) : diff;

            String effect = 'Moderate Momentum';
            String type = 'Positive';

            if ((p1 == 'Mars' || p2 == 'Mars') && (p1 == 'Mercury' || p2 == 'Mercury')) {
              effect = 'High Momentum Bullish Spike';
              type = 'Positive';
            } else if ((p1 == 'Saturn' || p2 == 'Saturn') && (p1 == 'Rahu' || p2 == 'Rahu')) {
              effect = 'Major Bearish Market Drag';
              type = 'Negative';
            } else if ((p1 == 'Jupiter' || p2 == 'Jupiter') && (p1 == 'Rahu' || p2 == 'Rahu')) {
              effect = 'Strong Trend Expansion';
              type = 'Positive';
            } else if (p1 == 'Moon' || p2 == 'Moon') {
              effect = 'Short-term Market Volatility';
              type = 'Neutral';
            }

            String dateStr = "$day ${monthNames[month - 1]}, $year";

            transits.add({
              'pair': '$p1 ☌ $p2',
              'time': 'Date: $dateStr',
              'status': 'Orb: ${exactOrb.toStringAsFixed(1)}°',
              'effect': effect,
              'type': type,
            });
          }
        }
      }
    }
    return transits;
  }

  // Calculate Daily Market Hours Timing (09:15 to 15:30)
  static List<Map<String, String>> calculateDailyIntraday(DateTime today) {
    List<Map<String, String>> dailyTransits = [];
    
    List<String> timeSlots = [
      '09:15 AM - 10:30 AM',
      '10:30 AM - 11:45 AM',
      '11:45 AM - 01:00 PM',
      '01:00 PM - 02:15 PM',
      '02:15 PM - 03:30 PM',
    ];

    double jdBase = getJulianDay(today);
    double moonLong = getPlanetLongitude('Moon', jdBase);
    double marsLong = getPlanetLongitude('Mars', jdBase);
    double mercLong = getPlanetLongitude('Mercury', jdBase);

    dailyTransits.add({
      'pair': 'Moon ☌ Intra-Orb',
      'time': timeSlots[0],
      'status': 'Opening Bell Phase',
      'effect': (moonLong % 30 < 15) ? 'Positive Opening Push' : 'Volatile Reversal',
      'type': (moonLong % 30 < 15) ? 'Positive' : 'Neutral',
    });

    dailyTransits.add({
      'pair': 'Mars / Mercury Aspect',
      'time': timeSlots[1],
      'status': 'Mid-Morning Trend',
      'effect': ((marsLong - mercLong).abs() < 60) ? 'Strong Momentum Shift' : 'Consolidation Phase',
      'type': 'Positive',
    });

    dailyTransits.add({
      'pair': 'Lunar Degree Shift',
      'time': timeSlots[2],
      'status': 'European Market Open',
      'effect': 'High Volatility Expected',
      'type': 'Neutral',
    });

    dailyTransits.add({
      'pair': 'Saturn Stability Check',
      'time': timeSlots[3],
      'status': 'Post-Lunch Phase',
      'effect': 'Bearish Pressure / Rangebound',
      'type': 'Negative',
    });

    dailyTransits.add({
      'pair': 'Closing Bell Conjunction',
      'time': timeSlots[4],
      'status': 'Final Market Hour',
      'effect': 'Strong Closing Move',
      'type': 'Positive',
    });

    return dailyTransits;
  }

  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

// ==================== 1. DAILY INTRADAY SCREEN ====================
class IntradayScreen extends StatelessWidget {
  const IntradayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<Map<String, String>> dailyTransits = SwephEngine.calculateDailyIntraday(today);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Intraday Timing (${today.day} ${SwephEngine.monthNames[today.month - 1]})'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: dailyTransits.length,
        itemBuilder: (context, i) => TransitCard(data: dailyTransits[i]),
      ),
    );
  }
}

// ==================== 2. MONTHLY ALL PLANETS SCREEN ====================
class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  DateTime selectedDate = DateTime(2026, 8);

  void changeMonth(int increment) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> transits = SwephEngine.calculateMonthlyAllTransits(
      selectedDate.year,
      selectedDate.month,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly All Transits Engine'), centerTitle: true),
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
                  '${SwephEngine.monthNames[selectedDate.month - 1]} ${selectedDate.year}',
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
          Text(
            'Calculated ${transits.length} Total Planetary Conjunctions',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: transits.isEmpty
                ? const Center(child: Text('No Major Planetary Conjunctions Found.'))
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

// ==================== 3. MANUAL CALCULATOR SCREEN ====================
class ManualSearchScreen extends StatefulWidget {
  const ManualSearchScreen({super.key});

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  String p1 = 'Mars';
  String p2 = 'Mercury';
  bool isRetrograde = false;
  bool isCombust = false;

  final List<String> planets = [
    'Mars', 'Saturn', 'Moon', 'Mercury', 'Jupiter', 'Venus', 'Rahu', 'Ketu'
  ];

  String calculateEffect() {
    if (p1 == p2) return 'Same Planet Selected';
    if ((p1 == 'Mars' && p2 == 'Mercury') || (p1 == 'Mercury' && p2 == 'Mars')) {
      return (isRetrograde || isCombust) ? 'Major Positive Momentum' : 'General Positive Momentum';
    }
    if ((p1 == 'Saturn' && p2 == 'Rahu') || (p1 == 'Rahu' && p2 == 'Saturn')) {
      return 'Major Negative Momentum / Bearish';
    }
    if ((p1 == 'Jupiter' && p2 == 'Rahu') || (p1 == 'Rahu' && p2 == 'Jupiter')) {
      return 'Strong Positive Trend Expansion';
    }
    return 'General Market Impact / Volatile';
  }

  @override
  Widget build(BuildContext context) {
    String result = calculateEffect();
    bool isPos = result.contains('Positive') || result.contains('Expansion');

    return Scaffold(
      appBar: AppBar(title: const Text('Manual Conjunction Calculator'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Conjunction Pair:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: p1,
                    isExpanded: true,
                    items: planets.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) => setState(() => p1 = val!),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('+')),
                Expanded(
                  child: DropdownButton<String>(
                    value: p2,
                    isExpanded: true,
                    items: planets.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) => setState(() => p2 = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('Is Retrograde (Vakri)?'),
              value: isRetrograde,
              onChanged: (v) => setState(() => isRetrograde = v!),
            ),
            CheckboxListTile(
              title: const Text('Is Combust (Ast)?'),
              value: isCombust,
              onChanged: (v) => setState(() => isCombust = v!),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPos ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isPos ? Colors.green : Colors.red),
              ),
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPos ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ),
          ],
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
                Text(data['time']!, style: const TextStyle(fontSize: 12)),
                Text(data['status']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
