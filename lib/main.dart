import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../screens/boll_animation_screen.dart';
import '../screens/home_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      routes: {
        BollAnimationScreen.routeName: (ctx) => const BollAnimationScreen(),
      },
    ),
  );
}

class PhysicsCardDragDemo extends StatelessWidget {
  const PhysicsCardDragDemo({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const DraggableCard(
          child: FlutterLogo(
        size: 128,
      )),
    );
  }
}

class DraggableCard extends StatefulWidget {
  const DraggableCard({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _animation;

  void _runAnimation(Offset pixelsPerSeconds, Size size) {
    _animation = _controller
        .drive(AlignmentTween(begin: _dragAlignment, end: Alignment.center));

    // Calculate the velocity ti the unit interval, [0, 1]
    // used by Amination Controller
    final unitsPerSecondX = pixelsPerSeconds.dx / size.width;
    final unitsPerSecondY = pixelsPerSeconds.dx / size.height;

    final unitsSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(
      spring,
      0,
      1,
      -unitVelocity,
    );

    _controller.animateWith(simulation);

    // _controller.reset();
    // _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(details.delta.dx / (size.width / 2),
              details.delta.dy / (size.height / 2));
        });
      },
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}
