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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Monthly'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Manual Check'),
        ],
      ),
    );
  }
}

// ==================== 1. DAILY INTRADAY SCREEN ====================
class IntradayScreen extends StatelessWidget {
  const IntradayScreen({super.key});

  final List<Map<String, String>> intradayTransits = const [
    {
      'pair': 'Mars ☌ Mercury',
      'time': '09:30 AM - 10:45 AM',
      'status': 'Mercury Combust',
      'effect': 'Major Positive Momentum',
      'type': 'Positive'
    },
    {
      'pair': 'Moon ☌ Ketu',
      'time': '11:15 AM - 12:30 PM',
      'status': 'Normal Speed',
      'effect': 'Mixed / Volatile Momentum',
      'type': 'Neutral'
    },
    {
      'pair': 'Saturn ☌ Neptune',
      'time': '01:10 PM - 02:40 PM',
      'status': 'Bearish Sign',
      'effect': 'Major Negative Momentum',
      'type': 'Negative'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Market Timing (9:15 - 3:30)'), centerTitle: true),
      body: ListView.builder(
        itemCount: intradayTransits.length,
        itemBuilder: (context, i) => TransitCard(data: intradayTransits[i]),
      ),
    );
  }
}

// ==================== 2. MONTHLY SCREEN (WITH DYNAMIC MONTH SWITCHER) ====================
class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  DateTime selectedDate = DateTime(2026, 8); // Default: August 2026

  final List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Dynamic monthly transits base database
  List<Map<String, String>> getTransitsForSelectedMonth() {
    int month = selectedDate.month;
    int year = selectedDate.year;

    return [
      {
        'pair': 'Jupiter ☌ Rahu',
        'time': '${monthNames[month - 1]} 02, $year - ${monthNames[month - 1]} 08, $year',
        'status': 'Jupiter Direct',
        'effect': 'Positive Momentum',
        'type': 'Positive'
      },
      {
        'pair': 'Mercury ☌ Venus',
        'time': '${monthNames[month - 1]} 12, $year - ${monthNames[month - 1]} 18, $year',
        'status': 'Mercury Retrograde',
        'effect': 'Volatile / Positive Momentum',
        'type': 'Positive'
      },
      {
        'pair': 'Saturn ☌ Rahu',
        'time': '${monthNames[month - 1]} 22, $year - ${monthNames[month - 1]} 27, $year',
        'status': 'Bearish Sign',
        'effect': 'Major Negative Momentum',
        'type': 'Negative'
      },
    ];
  }

  void changeMonth(int increment) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> currentTransits = getTransitsForSelectedMonth();

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Astro Outlook'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Month Switcher Header
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
                  onPressed: () => changeMonth(-1), // Previous Month
                ),
                Text(
                  '${monthNames[selectedDate.month - 1]} ${selectedDate.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.tealAccent),
                  onPressed: () => changeMonth(1), // Next Month
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: currentTransits.length,
              itemBuilder: (context, i) => TransitCard(data: currentTransits[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 3. MANUAL SEARCH CALCULATOR ====================
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
  bool isBearishSign = false;

  final List<String> planets = [
    'Mars', 'Saturn', 'Moon', 'Mercury', 'Jupiter', 'Venus', 'Rahu', 'Ketu', 'Uranus', 'Neptune', 'Pluto'
  ];

  String calculateEffect() {
    if (p1 == 'Mars' && p2 == 'Mercury') {
      return (isRetrograde || isCombust) ? 'Major Positive Momentum' : 'General Positive Momentum';
    }
    if (p1 == 'Mars' && p2 == 'Jupiter') return 'General Negative Momentum';
    if (p1 == 'Mars' && p2 == 'Saturn') return isRetrograde ? 'Volatile / Minor Positive' : 'Negative Momentum';
    if (p1 == 'Saturn' && (p2 == 'Rahu' || p2 == 'Uranus' || p2 == 'Neptune')) {
      return isBearishSign ? 'Major Negative Momentum' : 'General Positive/Neutral';
    }
    if (p1 == 'Mercury' && p2 == 'Venus') {
      return (isCombust || isRetrograde) ? 'Positive Momentum' : 'Negative Momentum';
    }
    if (p1 == 'Jupiter' && (p2 == 'Rahu' || p2 == 'Ketu')) {
      return isRetrograde ? 'Negative Momentum' : 'Positive Momentum';
    }
    if (p1 == 'Moon' && p2 == 'Venus') return 'Majority Times Negative Momentum';
    
    return 'Neutral / General Market Effect';
  }

  @override
  Widget build(BuildContext context) {
    String result = calculateEffect();
    bool isPos = result.contains('Positive');

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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('+'),
                ),
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
            const Text('Conditions:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            CheckboxListTile(
              title: const Text('In Bearish Sign?'),
              value: isBearishSign,
              onChanged: (v) => setState(() => isBearishSign = v!),
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
              child: Column(
                children: [
                  const Text('Expected Market Momentum:', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(
                    result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPos ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SHARED WIDGETS ====================
class TransitCard extends StatelessWidget {
  final Map<String, String> data;
  const TransitCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    bool isPos = data['type'] == 'Positive';
    bool isNeu = data['type'] == 'Neutral';

    Color cardColor = isPos ? Colors.green : (isNeu ? Colors.amber : Colors.red);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: cardColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['pair']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  data['effect']!,
                  style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Time / Date: ${data['time']}'),
            Text('Condition: ${data['status']}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
