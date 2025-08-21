import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(SpaceXApp());

class SpaceXApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceX Launches',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF0B1426),
        scaffoldBackgroundColor: Color(0xFF0F1419),
        cardTheme: CardTheme(
          color: Color(0xFF1A1F2E),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0B1426),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      home: LaunchListPage(),
    );
  }
}

class LaunchListPage extends StatefulWidget {
  @override
  _LaunchListPageState createState() => _LaunchListPageState();
}

class _LaunchListPageState extends State<LaunchListPage> {
  List launches = [];
  bool loading = true;
  bool showSuccessOnly = false;
  int? selectedYear;
  int? selectedMonth;

  @override
  void initState() {
    super.initState();
    fetchLaunches();
  }

  Future<void> fetchLaunches() async {
    setState(() {
      loading = true;
    });

    final url = Uri.parse('https://api.spacexdata.com/v5/launches');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final filtered = showSuccessOnly
            ? data.where((launch) => launch['success'] == true).toList()
            : data;

        setState(() {
          launches = filtered;
          loading = false;
        });
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loading = false;
        launches = [];
      });
    }
  }

  List<int> getAvailableYears(List launches) {
    final years = launches
        .map((l) => DateTime.tryParse(l['date_utc'] ?? '')?.year)
        .where((y) => y != null)
        .cast<int>()
        .toSet()
        .toList();
    years.sort();
    return years;
  }

  List<int> getAvailableMonths(List launches, int? year) {
    final months = launches
        .where((l) => DateTime.tryParse(l['date_utc'] ?? '')?.year == year)
        .map((l) => DateTime.tryParse(l['date_utc'] ?? '')?.month)
        .where((m) => m != null)
        .cast<int>()
        .toSet()
        .toList();
    months.sort();
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final years = getAvailableYears(launches);
    final months = getAvailableMonths(launches, selectedYear);

    // Filter data berdasarkan tahun & bulan jika dipilih
    List filteredLaunches = launches.where((l) {
      final date = DateTime.tryParse(l['date_utc'] ?? '');
      if (selectedYear != null && date?.year != selectedYear) return false;
      if (selectedMonth != null && date?.month != selectedMonth) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1426),
              Color(0xFF0F1419),
              Color(0xFF1A1F2E),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  children: [
                    Icon(Icons.rocket_launch, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'SpaceX Launches',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF0B1426)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Sukses Only",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Switch(
                        value: showSuccessOnly,
                        onChanged: (value) {
                          setState(() {
                            showSuccessOnly = value;
                          });
                          fetchLaunches();
                        },
                        activeColor: Color(0xFF10B981),
                        activeTrackColor: Color(0xFF10B981).withOpacity(0.3),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withOpacity(0.3),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Dropdown Tahun
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        hint: Text('Pilih Tahun', style: TextStyle(color: Colors.white)),
                        dropdownColor: Color(0xFF1A1F2E),
                        items: years.map((y) => DropdownMenuItem(
                          value: y,
                          child: Text('$y', style: TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedYear = val;
                            selectedMonth = null; // reset bulan jika tahun berubah
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    // Dropdown Bulan
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        hint: Text('Pilih Bulan', style: TextStyle(color: Colors.white)),
                        dropdownColor: Color(0xFF1A1F2E),
                        items: months.map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            '${m.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.white),
                          ),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedMonth = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: loading
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Memuat data peluncuran...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : filteredLaunches.isEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.white38,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada data misi',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: filteredLaunches.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map launch = entry.value;
                              return _buildLaunchCard(context, launch, index);
                            }).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchCard(BuildContext context, Map launch, int index) {
    final name = launch['name'] ?? 'Tanpa Nama';
    final date = launch['date_utc']?.substring(0, 10) ?? '-';
    final success = launch['success'] == true;
    final details = launch['details'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LaunchDetailPage(launch: launch),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: success
                    ? [Color(0xFF1A1F2E), Color(0xFF0F4A3C)]
                    : [Color(0xFF1A1F2E), Color(0xFF4A1F2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: success 
                            ? Color(0xFF10B981).withOpacity(0.2)
                            : Color(0xFFEF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        success ? Icons.check_circle : Icons.cancel,
                        color: success ? Color(0xFF10B981) : Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, 
                                   size: 14, color: Colors.white60),
                              SizedBox(width: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: success 
                            ? Color(0xFF10B981).withOpacity(0.2)
                            : Color(0xFFEF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: success ? Color(0xFF10B981) : Color(0xFFEF4444),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        success ? "Sukses" : "Gagal",
                        style: TextStyle(
                          color: success ? Color(0xFF10B981) : Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (details.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    details.length > 120 
                        ? '${details.substring(0, 120)}...' 
                        : details,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Spacer(),
                    Text(
                      'Tap untuk detail',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF3B82F6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LaunchDetailPage extends StatelessWidget {
  final Map launch;

  LaunchDetailPage({required this.launch});

  @override
  Widget build(BuildContext context) {
    final name = launch['name'] ?? 'Tanpa Nama';
    final date = launch['date_utc'] ?? '-';
    final details = launch['details'] ?? 'Tidak ada deskripsi.';
    final success = launch['success'] == true;
    final rocketId = launch['rocket'] ?? 'N/A';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1426),
              Color(0xFF0F1419),
              Color(0xFF1A1F2E),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: success
                          ? [Color(0xFF1E3A8A), Color(0xFF10B981)]
                          : [Color(0xFF1E3A8A), Color(0xFFEF4444)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.rocket_launch,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(
                      'Status Misi',
                      success ? 'Sukses' : 'Gagal',
                      success ? Icons.check_circle : Icons.cancel,
                      success ? Color(0xFF10B981) : Color(0xFFEF4444),
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      'Tanggal Peluncuran',
                      _formatDate(date),
                      Icons.calendar_today,
                      Color(0xFF3B82F6),
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      'Rocket ID',
                      rocketId,
                      Icons.rocket,
                      Color(0xFF8B5CF6),
                    ),
                    SizedBox(height: 20),
                    Card(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  color: Color(0xFFF59E0B),
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Deskripsi Misi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              details,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}