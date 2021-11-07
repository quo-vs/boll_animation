import 'package:flutter/material.dart';

import '../models/animation_speed.dart';
import '../screens/boll_animation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _xSpeed = 0.0;
  var _ySpeed = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set animation speed',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              "Set Horizontal speed",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.0),
            ),
            const SizedBox(
              height: 50.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  _xSpeed.toString(),
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            Slider(
              min: 0.0,
              max: 10.0,
              activeColor: Colors.purple,
              inactiveColor: Colors.purple.shade100,
              thumbColor: Colors.pink,
              divisions: 10,
              label: '$_xSpeed',
              value: _xSpeed,
              onChanged: (value) {
                setState(() {
                  _xSpeed = value;
                });
              },
            ),
            const SizedBox(
              height: 50.0,
            ),
            const Text(
              "Set Vertical speed",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.0),
            ),
            const SizedBox(
              height: 50.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  _ySpeed.toString(),
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            Slider(
              min: 0.0,
              max: 10.0,
              activeColor: Colors.purple,
              inactiveColor: Colors.purple.shade100,
              thumbColor: Colors.pink,
              divisions: 10,
              label: '$_ySpeed',
              value: _ySpeed,
              onChanged: (value) {
                setState(() {
                  _ySpeed = value;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                  Navigator.of(context).pushNamed(
                    BollAnimationScreen.routeName, arguments: AnimationSpeed(x: _xSpeed, y: _ySpeed),
                  );
              }, 
              child: const Text(
                'Show Animation'
              )
            )
          ],
        ),
      ),
    );
  }
}
