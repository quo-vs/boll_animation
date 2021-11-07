import 'dart:async';

import 'package:flutter/material.dart';

import '../models/animation_speed.dart';
import '../utils/animation_helper.dart';

class BollAnimationScreen extends StatefulWidget {
  static const routeName = '/boll-animation';

  AnimationSpeed? animationSpeed;

  BollAnimationScreen({Key? key, required this.animationSpeed})
      : super(key: key);

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
        vsync: this, duration: const Duration(milliseconds: 1000));
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
    WidgetsBinding.instance?.addPostFrameCallback((_) => loopOnce(context));
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

    var speed = ModalRoute.of(context)?.settings.arguments as AnimationSpeed?;
    speed ??= widget.animationSpeed;
    if (speed != null) {
      setState(() {
        _animationSpeed = speed!;
        _runAnimation();
      });
    }
  }

  void _runAnimation() async {
    Alignment _end;
    if (firstRun) {
      firstRun = false;
      _end = AnimationHelper.findEndPointForFirstMove(_alignment, _animationSpeed);
    } else {
      _end = AnimationHelper.findEndPointForNextMove(_alignment, _animationSpeed);
    }

    _animation = _controller.drive(AlignmentTween(begin: _alignment, end: _end));

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
          elevation: 1,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          leading:  IconButton(
            onPressed: _willPopCallback,
            icon: const Icon(Icons.arrow_back),
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
    _controller.stop();
    var coordinates = AnimationHelper.getBollCoordinates(
        _screenWidth, _screenHeight, _alignment);

    setState(() {
      firstRun = true;
    });
    Navigator.pop(context, coordinates);
    return Future.value(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
