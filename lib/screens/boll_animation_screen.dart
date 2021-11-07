import 'dart:async';

import 'package:flutter/material.dart';

import '../models/animation_speed.dart';
import '../utils/animation_helper.dart';

class BollAnimationScreen extends StatefulWidget {
  static const routeName = '/boll-animation';

  const BollAnimationScreen({Key? key}) : super(key: key);

  @override
  _BollAnimationScreenState createState() => _BollAnimationScreenState();
}

class _BollAnimationScreenState extends State<BollAnimationScreen>
    with TickerProviderStateMixin {
  var _animationSpeed = AnimationSpeed(x: 1, y: 1);
  late AnimationController _controller;
  Alignment _alignment = Alignment.topLeft;
  late Animation<Alignment> _animation;
  late double _screenWidth;
  late double _screenHeight;

  var firstRun = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _controller.addListener(() {
      setState(() {
        _alignment = _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _runAnimation();
      }
    });
    //add this to access the context safely.
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => loopOnce(context)); 
  }

  Future<void> loopOnce(BuildContext context) async {
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    final speed = ModalRoute.of(context)?.settings.arguments as AnimationSpeed?;
    if (speed != null) {
      setState(() {
        _animationSpeed = speed;

        _runAnimation();
      });
    }
  }


  void _runAnimation() async {
    Alignment _end;
    if (firstRun) {
      firstRun = false;
      _end = AnimationHelper.findEndPointForFirstMove(
        _alignment, _animationSpeed);
    } else {
      _end = AnimationHelper.findEndPointForNextMove(
        _alignment, _animationSpeed);
    }

    // Calculate the velocity ti the unit interval, [0, 1]
    // used by Amination Controller
    // final unitsPerSecondX = pixelsPerSeconds.dx / size.width;
    // final unitsPerSecondY = pixelsPerSeconds.dx / size.height;

    // final unitsSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    // final unitVelocity = unitsSecond.distance;

    // final start = Offset(_alignment.x, _alignment.y);
    // final end = Offset(_end.x, _end.y);
    // final distance = (start - end).distance;


    // var gravity  = GravitySimulation(
    //   1,
    //   distance,
    //   2,
    //   1
    // );


    // const spring = SpringDescription(
    //   mass: 30,
    //   stiffness: 1,
    //   damping: 1,
    // );

    // final simulation = SpringSimulation(
    //   spring,
    //   0,
    //   1,
    //   -1,
    // );

    _animation =
        _controller.drive(AlignmentTween(begin: _alignment, end: _end));

    //_controller.animateWith(gravity);

     _controller.reset();
     _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        body: Align(
          alignment: _alignment,
          child: Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle, 
                color: Colors.deepOrangeAccent,
            ),
            height: 100,
            width: 100, 
          ),
        ),
      ),
    );
  }

  Future<bool> _willPopCallback() async {
    
    var point = AnimationHelper.getBollCoordinates(_screenWidth, _screenHeight, _alignment);
    
    setState(() {
      firstRun = true;
    });
    return Future.value(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
