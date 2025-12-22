import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final double width;
  final double height;
  final double elevation;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const GlassButton({
    super.key,
    required this.icon,
    required this.text,
    this.width = 100,
    this.height = 100,
    this.elevation = 0.4,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black, //Colors.deepPurpleAccent Colors.b,
    this.textColor = Colors.deepPurpleAccent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: iconColor),
              //const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}
