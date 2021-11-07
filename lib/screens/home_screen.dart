import 'dart:math';

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
  Point? _coordinates;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Animation Speed',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              "Set Horizontal Step Speed",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22.0),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  _xSpeed.toString(),
                  style: const TextStyle(
                      fontSize: 40.0, fontWeight: FontWeight.w900),
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
              "Set Vertical Step Speed",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22.0),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  _ySpeed.toString(),
                  style: const TextStyle(
                      fontSize: 40.0, fontWeight: FontWeight.w900),
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
                onPressed: () async {
                  if (_xSpeed == 0 && _ySpeed == 0) {
                    showErrorAlert(context, 'Please set at least one step speed.');
                    return;
                  }

                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => BollAnimationScreen(
                            animationSpeed:
                                AnimationSpeed(x: _xSpeed, y: _ySpeed)),
                        fullscreenDialog: true,
                      ));
                  if (result != null) {
                    setState(() {
                      _coordinates = result;
                    });
                  }
                },
                child: const Text('Show Animation')),
            const SizedBox(
              height: 50,
            ),
            if (_coordinates != null)
              Text(
                "Boll Coordinates: X:${_coordinates!.x} Y:${_coordinates!.y} ",
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 22.0),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> showErrorAlert(
      BuildContext context, String errorText) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(errorText),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
