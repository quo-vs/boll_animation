import 'dart:math';

import 'package:flutter/material.dart';

import '../models/parsed_double.dart';
import '../models/animation_speed.dart';

class AnimationHelper {
  static double animationSpeedRate = 0.001;  
  static MoveDirection previousMoveDirection = MoveDirection.left;

  static Alignment findEndPointForFirstMove(Alignment alignment, AnimationSpeed animationSpeed) 
  {
    Alignment _endPoint;
    if (animationSpeed.y == 0) {
      _endPoint = findEndPointHorizontal(alignment, MoveDirection.left, animationSpeed);
      previousMoveDirection = MoveDirection.left;
    } else if (animationSpeed.x == 0) {
      _endPoint = findEndPointVertical(alignment, MoveDirection.down, animationSpeed);
      previousMoveDirection = MoveDirection.down;
    } else {
      _endPoint = findEndPointMoveDownLeft(alignment, animationSpeed);
      previousMoveDirection = MoveDirection.downLeft;
    }
    return _endPoint;
  }

  static Alignment findEndPointForNextMove(Alignment alignment, AnimationSpeed animationSpeed) {
    Alignment _endPoint;
    if (animationSpeed.y == 0) {
      var _nextMoveDirection = previousMoveDirection == MoveDirection.left
          ? MoveDirection.right
          : MoveDirection.left;
      _endPoint = findEndPointHorizontal(alignment, _nextMoveDirection, animationSpeed);
      previousMoveDirection = _nextMoveDirection;
    } else if (animationSpeed.x == 0) {
      var _nextMoveDirection = previousMoveDirection == MoveDirection.up
          ? MoveDirection.down
          : MoveDirection.up;
      _endPoint = findEndPointVertical(alignment, _nextMoveDirection, animationSpeed);
      previousMoveDirection = _nextMoveDirection;
    } else {
      switch (previousMoveDirection) {
        case MoveDirection.downLeft:
          {
            if (isBiggerOREqual(alignment.x, 1.0) &&
                isLessOREqual(alignment.y, 1.0)) {
              _endPoint = findEndPointMoveDownRight(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.downRight;
            } else {
              _endPoint = findEndPointMoveUpLeft(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.upLeft;
            }
          }
          break;
        case MoveDirection.downRight:
          {
            if (isLessOREqual(alignment.x, -1.0) &&
                isLessOREqual(alignment.y, 1.0)) {
              _endPoint = findEndPointMoveDownLeft(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.downLeft;
            } else {
              _endPoint = findEndPointMoveUpRight(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.upRight;
            }
          }
          break;
        case MoveDirection.upLeft:
          {
            if (isBiggerOREqual(alignment.x, 1.0) &&
                isBiggerOREqual(alignment.y, -1.0)) {
              _endPoint = findEndPointMoveUpRight(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.upRight;
            } else {
              _endPoint = findEndPointMoveDownLeft(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.downLeft;
            }
          }
          break;
        case MoveDirection.upRight:
          {
            if (isLessOREqual(alignment.x, -1.0) &&
                isBiggerOREqual(alignment.y, -1.0)) {
              _endPoint = findEndPointMoveUpLeft(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.upLeft;
            } else {
              _endPoint = findEndPointMoveDownRight(alignment, animationSpeed);
              previousMoveDirection = MoveDirection.downRight;
            }
          }
          break;
        default:
          {
            _endPoint = (alignment);
          }
          break;
      }
    }

    return _endPoint;
  }

  static Alignment findEndPointHorizontal( 
    Alignment startPoint,
    MoveDirection direction,
    AnimationSpeed animationSpeed)
  {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    switch (direction) {
      case MoveDirection.left:
        {
          while (isLessOREqual(xStep, 1.0)) {
            xStep += animationSpeedRate * animationSpeed.x;
          }

          if (isBiggerOREqual(xStep, 1.0)) xStep = 1.0;
          return Alignment(xStep, yStep);
        }
      case MoveDirection.right:
        {
          while (isBiggerOREqual(xStep, -1.0)) {
            xStep -= animationSpeedRate * animationSpeed.x;
          }

          if (isLessOREqual(xStep, -1.0)) xStep = -1.0;
          return Alignment(xStep, yStep);
        }
      default:
        return Alignment(xStep, yStep);
    }
  }

  static Alignment findEndPointVertical(
    Alignment startPoint, 
    MoveDirection direction,
    AnimationSpeed animationSpeed) 
  {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    switch (direction) {
      case MoveDirection.down:
        {
          while (isLessOREqual(yStep, 1.0)) {
            yStep += animationSpeedRate * animationSpeed.y;
          }

          if (isBiggerOREqual(yStep, 1.0)) yStep = 1.0;
          return Alignment(xStep, yStep);
        }
      case MoveDirection.up:
        {
          while (isBiggerOREqual(yStep, -1.0)) {
            yStep -= animationSpeedRate * animationSpeed.y;
          }

          if (isLessOREqual(yStep, -1.0)) yStep = -1.0;
          return Alignment(xStep, yStep);
        }
      default:
        return Alignment(xStep, yStep);
    }
  }

  static Alignment findEndPointMoveDownLeft(
    Alignment startPoint, AnimationSpeed animationSpeed) 
  {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isLessOREqual(xStep, 1.0) && isLessOREqual(yStep, 1.0)) {
      xStep += animationSpeedRate * animationSpeed.x;
      yStep += animationSpeedRate * animationSpeed.y;
    }

    if (isBiggerOREqual(xStep, 1.0)) xStep = 1.0;
    if (isBiggerOREqual(yStep, 1.0)) yStep = 1.0;

    return Alignment(xStep, yStep);
  }

  static Alignment findEndPointMoveDownRight(
    Alignment startPoint,  AnimationSpeed animationSpeed) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isBiggerOREqual(xStep, -1.0) && isLessOREqual(yStep, 1.0)) {
      xStep -= animationSpeedRate * animationSpeed.x;
      yStep += animationSpeedRate * animationSpeed.y;
    }

    if (isLessOREqual(xStep, -1.0)) xStep = -1.0;
    if (isBiggerOREqual(yStep, 1.0)) yStep = 1.0;

    return Alignment(xStep, yStep);
  }

  static Alignment findEndPointMoveUpRight(
    Alignment startPoint,  AnimationSpeed animationSpeed)  
  {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isBiggerOREqual(xStep, -1.0) && isBiggerOREqual(yStep, -1.0)) {
      xStep -= animationSpeedRate * animationSpeed.x;
      yStep -= animationSpeedRate * animationSpeed.y;
    }

    if (isLessOREqual(xStep, -1.0)) xStep = -1.0;
    if (isLessOREqual(yStep, -1.0)) yStep = -1.0;

    return Alignment(xStep, yStep);
  }

  static Alignment findEndPointMoveUpLeft(
    Alignment startPoint, AnimationSpeed animationSpeed) {
    var xStep = startPoint.x;
    var yStep = startPoint.y;

    while (isLessOREqual(xStep, 1.0) && isBiggerOREqual(yStep, -1.0)) {
      xStep += animationSpeedRate * animationSpeed.x;
      yStep -= animationSpeedRate * animationSpeed.y;
    }

    if (isBiggerOREqual(xStep, 1.0)) xStep = 1.0;
    if (isLessOREqual(yStep, -1.0)) yStep = -1.0;

    return Alignment(xStep, yStep);
  } 

  static Point getBollCoordinates(double screenWidth, double screenHeight, Alignment alignment) {
    var halfOfHorizontalScreenInPixels = screenWidth / 2;
    var halfOfVerticalScreenInPixels = screenHeight / 2;

    var halfHorizontalCoef = 1 / halfOfHorizontalScreenInPixels;
    var halfVerticalCoef = 1 / halfOfVerticalScreenInPixels;
    var X = 0.0, Y = 0.0;

    if (alignment.x.isNegative) {
      X = (1 - alignment.x.abs()) / halfHorizontalCoef;
    } else {
      X = (1 - alignment.x) / halfHorizontalCoef;
      X += halfOfHorizontalScreenInPixels;
    }

    if (alignment.y.isNegative) {
      Y = (1 - alignment.y.abs()) / halfVerticalCoef;
    } else {
      Y = (1 - alignment.y) / halfVerticalCoef;
      Y += halfOfVerticalScreenInPixels;
    }

    return Point(X.round(), Y.round());
  }

  static ParsedDouble parceDouble(double a) {
    var asString = a.toStringAsFixed(10);
    var intPart = num.parse(asString.split('.')[0]);
    var decimalPart = num.parse(asString.split('.')[1]);
    decimalPart = decimalPart == 0 ? 1 : decimalPart;

    return ParsedDouble(intPart, decimalPart);
  }

  static bool isBiggerOREqual(double a, double b) {
    var aParsed = parceDouble(a);
    var bParsed = parceDouble(b);

    var intPartIsBigger = aParsed.intPart > bParsed.intPart;
    var positiveNumberIsBiggerOrEqual = (aParsed.intPart == bParsed.intPart && aParsed.intPart.isNegative && 
          bParsed.intPart.isNegative && aParsed.decimalPart <= bParsed.decimalPart);
    var negativeNumberIsBiggerOrEqual = (aParsed.intPart == bParsed.intPart && !aParsed.intPart.isNegative &&
            !bParsed.intPart.isNegative && aParsed.decimalPart >= bParsed.decimalPart);

    return intPartIsBigger || positiveNumberIsBiggerOrEqual || negativeNumberIsBiggerOrEqual;
  }

  static bool isLessOREqual(double a, double b) {
    var aParsed = parceDouble(a);
    var bParsed = parceDouble(b);

    var intPartIsLess = aParsed.intPart < bParsed.intPart;
    var positiveNumberIsLessOrEqual = (aParsed.intPart == bParsed.intPart && !aParsed.intPart.isNegative &&
            !bParsed.intPart.isNegative && aParsed.decimalPart <= bParsed.decimalPart);
    var negativeNumberIsLessOrEqual = (aParsed.intPart == bParsed.intPart && aParsed.intPart.isNegative &&
            bParsed.intPart.isNegative && aParsed.decimalPart >= bParsed.decimalPart);

    return intPartIsLess || positiveNumberIsLessOrEqual || negativeNumberIsLessOrEqual;
  }
}