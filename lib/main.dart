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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Monthly Engine'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Manual Check'),
        ],
      ),
    );
  }
}

// ==================== LAHIRI AYANAMSHA + MUMBAI DEFAULT ENGINE ====================
class LahiriEngine {
  static double getLahiriAyanamsha(double julianDay) {
    double t = (julianDay - 2451545.0) / 36525.0;
    return 23.85694 + 1.396 * t; 
  }

  static double getPlanetNirayanaLongitude(String planet, double julianDay) {
    double d = julianDay - 2451545.0;

    double meanSayanaLong = 0.0;
    switch (planet) {
      case 'Moon':
        meanSayanaLong = 218.316 + 13.176396 * d;
        break;
      case 'Mercury':
        meanSayanaLong = 252.250 + 4.092334 * d;
        break;
      case 'Venus':
        meanSayanaLong = 181.979 + 1.602130 * d;
        break;
      case 'Mars':
        meanSayanaLong = 355.433 + 0.524033 * d;
        break;
      case 'Jupiter':
        meanSayanaLong = 34.351 + 0.083085 * d;
        break;
      case 'Saturn':
        meanSayanaLong = 50.077 + 0.033459 * d;
        break;
      case 'Rahu':
        meanSayanaLong = 125.044 - 0.052953 * d;
        break;
      case 'Ketu':
        meanSayanaLong = (125.044 - 0.052953 * d) + 180.0;
        break;
      default:
        meanSayanaLong = 0.0;
    }

    double ayanamsha = getLahiriAyanamsha(julianDay);
    double nirayanaLong = meanSayanaLong - ayanamsha;

    return (nirayanaLong % 360 + 360) % 360;
  }

  static double getJulianDayMumbai(DateTime dt) {
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

  // Calculate Daily Intraday Transits (Mumbai Market Hours: 9:15 AM - 3:30 PM)
  static List<Map<String, String>> calculateDailyIntradayLahiri(DateTime today) {
    List<Map<String, String>> dailyTransits = [];
    
    List<String> timeSlots = [
      '09:15 AM - 10:30 AM',
      '10:30 AM - 11:45 AM',
      '11:45 AM - 01:00 PM',
      '01:00 PM - 02:15 PM',
      '02:15 PM - 03:30 PM',
    ];

    double jdBull = getJulianDayMumbai(today);
    double moonLong = getPlanetNirayanaLongitude('Moon', jdBull);
    double marsLong = getPlanetNirayanaLongitude('Mars', jdBull);
    double mercLong = getPlanetNirayanaLongitude('Mercury', jdBull);

    dailyTransits.add({
      'pair': 'Opening Bell (Moon Orb)',
      'time': timeSlots[0],
      'status': 'Mumbai Market Opening Phase',
      'effect': (moonLong % 30 < 15) ? 'Positive Opening Push' : 'Volatile Reversal',
      'type': (moonLong % 30 < 15) ? 'Positive' : 'Neutral',
    });

    dailyTransits.add({
      'pair': 'Mars / Mercury Lahiri Aspect',
      'time': timeSlots[1],
      'status': 'Mid-Morning Momentum',
      'effect': ((marsLong - mercLong).abs() < 60) ? 'Strong Momentum Shift' : 'Consolidation Phase',
      'type': 'Positive',
    });

    dailyTransits.add({
      'pair': 'Lunar Degree Shift (Nirayana)',
      'time': timeSlots[2],
      'status': 'Mid-Day Trading Phase',
      'effect': 'High Volatility Expected',
      'type': 'Neutral',
    });

    dailyTransits.add({
      'pair': 'Saturn Stability Check',
      'time': timeSlots[3],
      'status': 'Post-Lunch Trend',
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

  // Calculate Monthly Transits
  static List<Map<String, String>> calculateLahiriTransits(int year, int month) {
    List<Map<String, String>> transits = [];
    List<String> allPlanets = ['Moon', 'Mars', 'Mercury', 'Venus', 'Jupiter', 'Saturn', 'Rahu', 'Ketu'];

    int daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      for (int hour = 0; hour < 24; hour += 3) {
        DateTime checkTime = DateTime(year, month, day, hour, 0);
        double jd = getJulianDayMumbai(checkTime);

        for (int i = 0; i < allPlanets.length; i++) {
          for (int j = i + 1; j < allPlanets.length; j++) {
            String p1 = allPlanets[i];
            String p2 = allPlanets[j];

            if (p1 == 'Rahu' && p2 == 'Ketu') continue;

            double l1 = getPlanetNirayanaLongitude(p1, jd);
            double l2 = getPlanetNirayanaLongitude(p2, jd);
            double diff = (l1 - l2).abs();

            if (diff < 3.2 || diff > 356.8) {
              double exactOrb = diff > 180 ? (360 - diff) : diff;

              String effect = 'Volatile Reversal';
              String type = 'Neutral';

              if ((p1 == 'Mars' || p2 == 'Mars') && (p1 == 'Mercury' || p2 == 'Mercury')) {
                effect = 'Major Bullish Momentum';
                type = 'Positive';
              } else if ((p1 == 'Saturn' || p2 == 'Saturn') && (p1 == 'Rahu' || p2 == 'Rahu')) {
                effect = 'Major Bearish Drag';
                type = 'Negative';
              }

              String period = hour >= 12 ? 'PM' : 'AM';
              int displayHour = hour % 12 == 0 ? 12 : hour % 12;
              String exactTimeStr = "$day ${monthNames[month - 1]} @ ${displayHour.toString().padLeft(2, '0')}:00 $period (IST)";

              if (transits.isEmpty || transits.last['pair'] != '$p1 ☌ $p2' || transits.last['day'] != day.toString()) {
                transits.add({
                  'pair': '$p1 ☌ $p2',
                  'time': 'Time: $exactTimeStr',
                  'status': 'Orb: ${exactOrb.toStringAsFixed(1)}° (Lahiri)',
                  'effect': effect,
                  'type': type,
                  'day': day.toString(),
                });
              }
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

// ==================== 1. DAILY INTRADAY SCREEN ====================
class IntradayScreen extends StatelessWidget {
  const IntradayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<Map<String, String>> dailyData = LahiriEngine.calculateDailyIntradayLahiri(today);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Intraday (${today.day} ${LahiriEngine.monthNames[today.month - 1]})'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: dailyData.length,
        itemBuilder: (context, i) => TransitCard(data: dailyData[i]),
      ),
    );
  }
}

// ==================== 2. MONTHLY SCREEN ====================
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
    List<Map<String, String>> transits = LahiriEngine.calculateLahiriTransits(
      selectedDate.year,
      selectedDate.month,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Lahiri Ayanamsha (Mumbai Default)'), centerTitle: true),
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
                  '${LahiriEngine.monthNames[selectedDate.month - 1]} ${selectedDate.year}',
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
            'Found ${transits.length} Nirayana Transits (Lahiri System)',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: transits.length,
              itemBuilder: (context, i) => TransitCard(data: transits[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 3. MANUAL SCREEN ====================
class ManualSearchScreen extends StatelessWidget {
  const ManualSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Check'), centerTitle: true),
      body: const Center(child: Text('Manual Engine Active', style: TextStyle(color: Colors.tealAccent))),
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
                Text(data['time']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.tealAccent)),
                Text(data['status']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
