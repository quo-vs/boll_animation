import 'package:flutter/material.dart';

import '../screens/boll_animation_screen.dart';
import '../screens/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      routes: {
        BollAnimationScreen.routeName: (ctx) => const BollAnimationScreen(),
      },
    ),
  );
}


