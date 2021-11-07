import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:boll_animation/models/animation_speed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

enum MoveDirection {
  DownLeft,
  DownRight,
  UpLeft,
  UpRight,
  Left,
  Right,
  Up,
  Down
}

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
  //late Timer _timer;
  late double _screenWidth;
  late double _screenHeight;
  double animationSpeedRate = 0.01;
  int coef = 1000000000;
  double endBound = 0.0;

  late MoveDirection previousMoveDirection;

  var firstRun = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    // _timer = Timer.periodic(Duration(milliseconds: 3000), (timer) {
    //   _runAnimation();
    //  });
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
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => loopOnce(context)); //i add this to access the context safely.
  }

  Future<void> loopOnce(BuildContext context) async {
    // await Future.delayed(Duration(seconds: 1));
    await _controller.forward();
    //we can add duration here
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

  bool isEqual(double a, double b) {
    var aString = a.toStringAsFixed(10);
    var bString = b.toStringAsFixed(10);

    var aIntPart = int.parse(aString.split('.')[0]);
    var aDecimalPart = int.parse(aString.split('.')[1]);

    var bIntPart = int.parse(bString.split('.')[0]);
    var bDecimalPart = int.parse(bString.split('.')[1]);

    return (aIntPart == bIntPart && aDecimalPart == bDecimalPart) ||
        (++aIntPart == bIntPart && aDecimalPart > 9999999999) ||
        (--aIntPart == bIntPart && aDecimalPart > 9999999999);
  }

  bool isBiggerOREqual(double a, double b) {
    var aString = a.toStringAsFixed(10);
    var bString = b.toStringAsFixed(10);
    var decimalPartIfZero = 000000001;

    var aIntPart = num.parse(aString.split('.')[0]);
    var aDecimalPart = num.parse(aString.split('.')[1]);
    aDecimalPart = aDecimalPart == 0 ? decimalPartIfZero : aDecimalPart;

    var bIntPart = num.parse(bString.split('.')[0]);
    var bDecimalPart = num.parse(bString.split('.')[1]);
    bDecimalPart = bDecimalPart == 0 ? decimalPartIfZero : bDecimalPart;

    return  (aIntPart > bIntPart) ||
            (aIntPart == bIntPart && aIntPart.isNegative && bIntPart.isNegative && aDecimalPart <= bDecimalPart) ||
            (aIntPart == bIntPart && !aIntPart.isNegative && !bIntPart.isNegative && aDecimalPart >= bDecimalPart);
  }

  bool isLessOREqual(double a, double b) {
    var aString = a.toStringAsFixed(10);
    var bString = b.toStringAsFixed(10);
    var decimalPartIfZero = 1;

    var aIntPart = num.parse(aString.split('.')[0]);
    var aDecimalPart = num.parse(aString.split('.')[1]);
    aDecimalPart = aDecimalPart == 0 ? decimalPartIfZero : aDecimalPart;

    var bIntPart = num.parse(bString.split('.')[0]);
    var bDecimalPart = num.parse(bString.split('.')[1]);
    bDecimalPart = bDecimalPart == 0 ? decimalPartIfZero : bDecimalPart;

    return (aIntPart < bIntPart) ||
        (aIntPart == bIntPart && !aIntPart.isNegative && !bIntPart.isNegative && aDecimalPart <= bDecimalPart) ||
        (aIntPart == bIntPart && aIntPart.isNegative && bIntPart.isNegative && aDecimalPart >= bDecimalPart);
  }

  Alignment _findEndPointForFirstMove() {
    Alignment _endPoint;
    if (_animationSpeed.y == 0) {
      _endPoint = _findEndPointHorizontal(_alignment, MoveDirection.Left);
      previousMoveDirection = MoveDirection.Left;
    } else if (_animationSpeed.x == 0) {
      _endPoint = _findEndPointVertical(_alignment, MoveDirection.Down);
      previousMoveDirection = MoveDirection.Down;
    } else {
      _endPoint = _findEndPointMoveDownLeft(_alignment);
      previousMoveDirection = MoveDirection.DownLeft;
    }
    return _endPoint;
  }

  Alignment _findEndPointForNextMove() {
    Alignment _endPoint;
    if (_animationSpeed.y == 0) {
      var _nextMoveDirection = previousMoveDirection == MoveDirection.Left
          ? MoveDirection.Right
          : MoveDirection.Left;
      _endPoint = _findEndPointHorizontal(_alignment, _nextMoveDirection);
      previousMoveDirection = _nextMoveDirection;
    } else if (_animationSpeed.x == 0) {
      var _nextMoveDirection = previousMoveDirection == MoveDirection.Up
          ? MoveDirection.Down
          : MoveDirection.Up;
      _endPoint = _findEndPointVertical(_alignment, _nextMoveDirection);
      previousMoveDirection = _nextMoveDirection;
    } else {
      switch (previousMoveDirection) {
        case MoveDirection.DownLeft:
          {
            if (isBiggerOREqual(_alignment.x, 1.0) && isLessOREqual(_alignment.y, 1.0)) {
              _endPoint = _findEndPointMoveDownRight(_alignment);
              previousMoveDirection = MoveDirection.DownRight;
            } else {
              _endPoint = _findEndPointMoveUpLeft(_alignment);
              previousMoveDirection = MoveDirection.UpLeft;
            }
          }
          break;
        case MoveDirection.DownRight:
          {
            if (isLessOREqual(_alignment.x, -1.0) && isLessOREqual(_alignment.y, 1.0)) {
              _endPoint = _findEndPointMoveDownLeft(_alignment);
              previousMoveDirection = MoveDirection.DownLeft;
            } else {
              _endPoint = _findEndPointMoveUpRight(_alignment);
              previousMoveDirection = MoveDirection.UpRight;
            }
          }
          break;
        case MoveDirection.UpLeft:
          {
            if (isBiggerOREqual(_alignment.x, 1.0) && isBiggerOREqual(_alignment.y, -1.0)) {
              _endPoint = _findEndPointMoveUpRight(_alignment);
              previousMoveDirection = MoveDirection.UpRight;
            } else {
              _endPoint = _findEndPointMoveDownLeft(_alignment);
              previousMoveDirection = MoveDirection.DownLeft;
            }
          }
          break;
        case MoveDirection.UpRight:
          {
            if (isLessOREqual(_alignment.x, -1.0) && isBiggerOREqual(_alignment.y, -1.0)) {
              _endPoint = _findEndPointMoveUpLeft(_alignment);
              previousMoveDirection = MoveDirection.UpLeft;
            } else {
              _endPoint = _findEndPointMoveDownRight(_alignment);
              previousMoveDirection = MoveDirection.DownRight;
            }
          }
          break;
        default:
          {
            _endPoint = (_alignment);
          }
          break;
      }
  }

    return _endPoint;
  }

  Alignment _findEndPointHorizontal(
      Alignment startPoint, MoveDirection direction) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    switch (direction) {
      case MoveDirection.Left:
        {
          while (isLessOREqual(xStep, 1.0)) {
            xStep += animationSpeedRate * _animationSpeed.x;
          }

          if (isBiggerOREqual(xStep, 1.0)) xStep = 1.0;
          return Alignment(xStep, yStep);
        }
      case MoveDirection.Right:
        {
          while (isBiggerOREqual(xStep, -1.0)) {
            xStep -= animationSpeedRate * _animationSpeed.x;
          }

          if (isLessOREqual(xStep, -1.0)) xStep = -1.0;
          return Alignment(xStep, yStep);
        }
      default:
        return Alignment(xStep, yStep);
    }
  }

  Alignment _findEndPointVertical(
      Alignment startPoint, MoveDirection direction) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    switch (direction) {
      case MoveDirection.Down:
        {
          while (isLessOREqual(yStep, 1.0)) {
            yStep += animationSpeedRate * _animationSpeed.y;
          }

          if (isBiggerOREqual(yStep, 1.0)) yStep = 1.0;
          return Alignment(xStep, yStep);
        }
      case MoveDirection.Up:
        {
          while (isBiggerOREqual(yStep, -1.0)) {
            yStep -= animationSpeedRate * _animationSpeed.y;
          }

          if (isLessOREqual(yStep, -1.0)) yStep = -1.0;
          return Alignment(xStep, yStep);
        }
      default:
        return Alignment(xStep, yStep);
    }
  }

  Alignment _findEndPointMoveDownLeft(Alignment startPoint) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isLessOREqual(xStep, 1.0) && isLessOREqual(yStep, 1.0)) {
      xStep += animationSpeedRate * _animationSpeed.x;
      yStep += animationSpeedRate * _animationSpeed.y;
    }

    if (isBiggerOREqual(xStep, 1.0)) xStep = 1.0;
    if (isBiggerOREqual(yStep, 1.0)) yStep = 1.0;

    return Alignment(xStep, yStep);
  }

  Alignment _findEndPointMoveDownRight(Alignment startPoint) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isBiggerOREqual(xStep, -1.0) && isLessOREqual(yStep, 1.0)) {
      xStep -= animationSpeedRate * _animationSpeed.x;
      yStep += animationSpeedRate * _animationSpeed.y;
    }

    if (isLessOREqual(xStep, -1.0)) xStep = -1.0;
    if (isBiggerOREqual(yStep, 1.0)) yStep = 1.0;

    return Alignment(xStep, yStep);
  }

  _findEndPointMoveUpRight(Alignment startPoint) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isBiggerOREqual(xStep, -1.0) && isBiggerOREqual(yStep, -1.0)) {
      xStep -= animationSpeedRate * _animationSpeed.x;
      yStep -= animationSpeedRate * _animationSpeed.y;
    }

    if (isLessOREqual(xStep, -1.0)) xStep = -1.0;
    if (isLessOREqual(yStep, -1.0)) yStep = -1.0;

    return Alignment(xStep, yStep);
  }

  _findEndPointMoveUpLeft(Alignment startPoint) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isLessOREqual(xStep, 1.0) && isBiggerOREqual(yStep, -1.0)) {
      xStep += animationSpeedRate * _animationSpeed.x;
      yStep -= animationSpeedRate * _animationSpeed.y;
    }

    if (isBiggerOREqual(xStep, 1.0)) xStep = 1.0;
    if (isLessOREqual(yStep, -1.0)) yStep = -1.0;

    return Alignment(xStep, yStep);
  }

  void _runAnimation() async {
    Alignment _end;
    if (firstRun) {
      firstRun = false;
      _end = _findEndPointForFirstMove();
    } else {
      _end = _findEndPointForNextMove();
    }

    //  else if (isEqual(_alignment.x, 1.0) && isLessOREqual(_alignment.y, 1.0)) {
    //   _end = _findEndPointMoveDownRight(_alignment);
    // } else if (isBiggerOREqual(_alignment.x, 0.0) &&
    //     isEqual(_alignment.y, 1.0)) {
    //   _end = _findEndPointMoveUpRight(_alignment);
    // } else if (isLessOREqual(_alignment.x, 0.0) && isEqual(_alignment.y, 1.0)) {
    //   _end = _findEndPointMoveUpLeft(_alignment);
    // } else {
    //   _end = _findEndPointMoveDownLeft(_alignment);
    // }

    _animation =
        _controller.drive(AlignmentTween(begin: _alignment, end: _end));

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
                shape: BoxShape.circle, //making box to circle
                color: Colors.deepOrangeAccent //background of container
                ),
            height: 100, //value from animation controller
            width: 100, //value from animation controller
          ),
        ),
      ),
    );
  }

  Future<bool> _willPopCallback() async {
    // _timer.cancel();
    var halfOfHorizontalScreenInPixels = _screenWidth / 2;
    var halfOfVerticalScreenInPixels = _screenHeight / 2;

    var halfHorizontalCoef = 1 / halfOfHorizontalScreenInPixels;
    var halfVerticalCoef = 1 / halfOfVerticalScreenInPixels;
    var X = 0.0;
    var Y = 0.0;

    var resultX = 0;
    var resultY = 0;

    if (_alignment.x.isNegative) {
      X = (1 - _alignment.x.abs()) / halfHorizontalCoef;
    } else {
      X = (1 - _alignment.x) / halfHorizontalCoef;
      X += halfOfHorizontalScreenInPixels;
    }
    resultX = X.round();

    if (_alignment.y.isNegative) {
      Y = (1 - _alignment.y.abs()) / halfVerticalCoef;
    } else {
      Y = (1 - _alignment.y) / halfVerticalCoef;
      Y += halfOfVerticalScreenInPixels;
    }
    resultY = Y.round();
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
