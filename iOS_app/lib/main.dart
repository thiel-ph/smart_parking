import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ParkingLots {
  final String name;
  num distance;
  bool isGreyedOut;
  num capacity;
  num available;

  ParkingLots({
    required this.name,
    this.distance = 0.0,
    this.isGreyedOut = false,
    this.capacity = 50,
    this.available = 0,
  });
}

class MyListPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  final List<ParkingLots> allParkingLots = [
    ParkingLots(
        name: 'Fourth Street Garage (44 S. 4th St.)',
        distance: 0.4,
        isGreyedOut: false,
        available: 0,
        capacity: 40),
    ParkingLots(
        name: 'West Garage (350 S. 4th St.)',
        distance: 0.8,
        isGreyedOut: false),
    ParkingLots(
        name: 'Library Street',
        distance: 0.9,
        isGreyedOut: false,
        available: 10,
        capacity: 40),
    ParkingLots(
        name: 'South Garage (377 S. 7th St.)',
        distance: 1.2,
        isGreyedOut: false),
    ParkingLots(
        name: 'North Garage (65 S. 10th St.)',
        distance: 1.5,
        isGreyedOut: false),
    ParkingLots(name: 'College Lane', distance: 1.8, isGreyedOut: true),
    ParkingLots(name: 'Maple Avenue', distance: 2.3, isGreyedOut: false),
    ParkingLots(
        name: 'South Campus Garage (1278 S. 10th St.)',
        distance: 3.1,
        isGreyedOut: true),
  ];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void fetchData() async {
    final url = Uri.parse('http://52.53.253.65:5000/parking/status');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool isOccupied = data['isOccupied'];

        setState(() {
          allParkingLots
              .firstWhere(
                  (lot) => lot.name == 'Fourth Street Garage (44 S. 4th St.)')
              .available = isOccupied ? 0 : 1;
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    allParkingLots.sort((a, b) {
      if ((a.available > 0) && (b.available == 0)) {
        return -1;
      }
      if ((a.available == 0) && (b.available > 0)) {
        return 1;
      }

      return a.distance.compareTo(b.distance);
    });

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Image.asset('images/smart_parking_logo.png'),
          ),
          Text(
            "Find nearby parking spaces:",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: allParkingLots.length,
                  itemBuilder: (context, index) {
                    final item = allParkingLots[index];
                    final isClickable = item.available > 0;
                    return AnimatedContainer(
                      duration:
                          Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          if (isClickable)
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            )
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isClickable ? Colors.black : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                            'Distance: ${item.distance} miles. Spaces: ${item.available}/${item.capacity}.'),
                        tileColor: Colors.white,
                        onTap: () {
                          if (isClickable) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(item: item),
                                ));
                          }
                        },
                      ),
                    );
                  },
                ),
                // Gradient overlay
                Positioned(
                  top: 0, 
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(1.0),
                          Colors.white.withOpacity(0.0)
                        ],
                        stops: [0.2, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    ),
    home: MyListPage(),
  ));
}

class DetailPage extends StatelessWidget {
  final ParkingLots item;

  DetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SafeArea(
              child:
                  Image.asset('images/fourth_street_garage.png'),
            ),
            SizedBox(height: 16), // Spacer
            Text(
              'Distance: ${item.distance} miles',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8), // Spacer
            Text(
              'Availability: ${item.available}/${item.capacity}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24), // Spacer
            ElevatedButton(
              onPressed: () async {
                final Uri url =
                    Uri.parse('https://maps.app.goo.gl/BuhTULRUN93wj2iK8');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open the URL')),
                  );
                }
              },
              child: Text('Get direction'),
            ),
          ],
        ),
      ),
    );
  }
}
