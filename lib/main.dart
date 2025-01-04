import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int wallet = 10;
  String selectedGameType = "2 Alike";
  String resultMessage = "";
  final TextEditingController wagerController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<int> diceRolls = [1, 1, 1, 1];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> rollDice() async {
    _animationController.reset();
    _animationController.forward();
    await Future.delayed(const Duration(seconds: 1));

    Random random = Random();
    setState(() {
      diceRolls = List.generate(4, (_) => random.nextInt(6) + 1);
    });
  }

  int calculateMultiplier(String gameType) {
    Map<int, int> counts = {};
    for (var dice in diceRolls) {
      counts[dice] = (counts[dice] ?? 0) + 1;
    }

    int maxCount = counts.values.reduce(max);
    int requiredMatches = gameType == "2 Alike"
        ? 2
        : gameType == "3 Alike"
        ? 3
        : 4;

    return maxCount >= requiredMatches ? requiredMatches : -requiredMatches;
  }

  void addCoins() {
    TextEditingController coinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Coins"),
          content: TextField(
            controller: coinController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter coins (max 100)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                int? coins = int.tryParse(coinController.text);
                if (coins == null || coins <= 0 || coins > 100) {
                  Fluttertoast.showToast(
                    msg: "Invalid input. Please enter a number between 1 and 100.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }
                setState(() {
                  wallet += coins;
                });
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Added $coins coins to your wallet!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void playGame() async {
    int wager = int.tryParse(wagerController.text) ?? 0;

    if (wager <= 0 || wager > wallet) {
      Fluttertoast.showToast(
        msg: "Invalid wager! Please enter a valid amount.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    await rollDice();
    int multiplier = calculateMultiplier(selectedGameType);

    setState(() {
      int coinsWonOrLost = wager * multiplier;
      wallet += coinsWonOrLost;
      resultMessage =
      "Rolls: ${diceRolls.join(', ')}\n${multiplier > 0 ? 'Won' : 'Lost'} ${coinsWonOrLost.abs()} coins!";
    });

    Fluttertoast.showToast(
      msg: multiplier > 0
          ? "🎉 You won ${wager * multiplier} coins!"
          : "😞 You lost ${wager * multiplier.abs()} coins.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: multiplier > 0 ? Colors.green : Colors.red,
      textColor: Colors.white,
    );

    wagerController.clear();
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.brown.shade200,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.brown.shade200,
          title: Text(
            'Dice Game',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 70.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.brown.shade300
                  ),
                  child: Center(
                    child: Text(
                      'Dice Game',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: openProfile,
              ),
              ListTile(
                leading: Icon(Icons.add_circle),
                title: Text('Add Coins'),
                onTap: addCoins,
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  exit(0);
                },
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Wallet: $wallet coins',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: wagerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Wager',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButton<String>(
                value: selectedGameType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGameType = newValue!;
                  });
                },
                items: <String>["2 Alike", "3 Alike", "4 Alike"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 24.0),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: playGame,
                child: Text(
                  'Go',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: diceRolls.map((roll) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Transform.rotate(
                          angle: _animation.value * pi * 2,
                          child: Image.asset(
                            'lib/assets/images/dice_$roll.png',
                            width: 80.0,
                            height: 80.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    resultMessage,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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

class ProfilePage extends StatelessWidget {
  ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.brown.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: Arve Khandelwal", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Email: arvekhandelwal382@gmail.com", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Phone: +91 9217319921", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
