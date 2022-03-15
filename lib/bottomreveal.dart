import 'package:flutter/material.dart';
import 'dart:math' as math;

class BottomRevealController {
  Function? close;
  Function? open;
  Function? toggle;
}

class BottomReveal extends StatefulWidget {
  final BottomRevealController? controller;
  final Widget body;
  final Color backColor;
  final Color frontColor;
  final double borderRadius;
  final double revealHeight;
  final double revealWidth;
  final Widget? rightContent;
  final Widget? bottomContent;
  final IconData openIcon;
  final IconData closeIcon;

  const BottomReveal(
      {Key? key,
      this.controller,
      required this.body,
      this.backColor = Colors.grey,
      this.frontColor = Colors.white,
      this.borderRadius = 50,
      this.revealHeight = 70.0,
      this.revealWidth = 70.0,
      this.rightContent,
      this.bottomContent,
      required this.openIcon,
      required this.closeIcon})
      : super(key: key);
  @override
  _BottomRevealState createState() => _BottomRevealState();
}

class _BottomRevealState extends State<BottomReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? bottomMargin;
  double? rightMargin;
  late bool opened;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    opened = false;
    bottomMargin = 0;
    rightMargin = 0;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller?.open = _open;
    widget.controller?.close = _close;
    widget.controller?.toggle = _toggle;
    return Scaffold(
      backgroundColor: widget.backColor,
      floatingActionButton: _buildActionButton(),
      body: Stack(
        children: <Widget>[
          if (widget.rightContent != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                alignment: Alignment.bottomCenter,
                width: widget.revealWidth,
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 90),
                child: widget.rightContent,
              ),
            ),
          if (widget.bottomContent != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  padding: EdgeInsets.only(
                      left: 8.0,
                      right: widget.revealWidth,
                      bottom: 8.0,
                      top: 8.0),
                  alignment: Alignment.centerRight,
                  height: widget.revealHeight - 15,
                  child: widget.bottomContent),
            ),
          AnimatedPositioned(
            curve: Curves.easeInOutBack,
            duration: const Duration(milliseconds: 500),
            bottom: bottomMargin,
            right: rightMargin,
            top: -bottomMargin!,
            left: -rightMargin!,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                  color: widget.frontColor,
                  borderRadius: opened
                      ? BorderRadius.only(
                          bottomRight: Radius.circular(widget.borderRadius))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: widget.backColor.withOpacity(0.5),
                      blurRadius: 5.0,
                    ),
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(widget.borderRadius)),
                child: opened && !_controller.isAnimating
                    ? Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          widget.body,
                          Container(
                            color: Colors.black12,
                          )
                        ],
                      )
                    : widget.body,
              ),
            ),
          )
        ],
      ),
    );
  }

  FloatingActionButton _buildActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.pink,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.rotationZ(_controller.value * .5 * math.pi),
              child: Icon(!_controller.isDismissed
                  ? widget.openIcon
                  : widget.closeIcon));
        },
      ),
      onPressed: () {
        _toggle();
      },
    );
  }

  void _open() {
    setState(() {
      rightMargin = widget.revealWidth;
      bottomMargin = widget.revealHeight;
      _controller.reverse();
      opened = true;
    });
  }

  void _close() {
    setState(() {
      rightMargin = 0;
      bottomMargin = 0;
      _controller.forward();
      opened = false;
    });
  }

  _toggle() {
    if (opened) {
      _close();
    } else {
      _open();
    }
  }
}
