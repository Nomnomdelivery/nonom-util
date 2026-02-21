import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  const TicketClipper({this.cornerRadius = 10, this.notchRadius = 12});
  final double cornerRadius;
  final double notchRadius;
  @override
  Path getClip(Size size) {
    final Path path = Path();

    path.moveTo(cornerRadius, 0);

    // Top edge with top-left rounded corner
    path.arcToPoint(
      Offset(0, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );
    path.lineTo(
      0,
      size.height / 3 - notchRadius,
    ); // Left edge up to the first notch

    // First notch on the left edge
    // path.arcToPoint(
    //   Offset(0, size.height / 3 + notchRadius),
    //   radius: Radius.circular(notchRadius),
    // );
    path.lineTo(
      0,
      2 * size.height / 3 - notchRadius,
    ); // Left edge up to the second notch

    // Second notch on the left edge
    path.arcToPoint(
      Offset(0, 2 * size.height / 3 + notchRadius),
      radius: Radius.circular(notchRadius),
    );
    path.lineTo(
      0,
      size.height - cornerRadius,
    ); // Left edge to the bottom-left corner

    // Bottom-left rounded corner
    path.arcToPoint(
      Offset(cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Bottom edge
    path.lineTo(size.width - cornerRadius, size.height);

    // Bottom-right rounded corner
    path.arcToPoint(
      Offset(size.width, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Right edge with two notches
    path.lineTo(size.width, 2 * size.height / 3 + notchRadius);
    path.arcToPoint(
      Offset(size.width, 2 * size.height / 3 - notchRadius),
      radius: Radius.circular(notchRadius),
    );
    path.lineTo(size.width, size.height / 3 + notchRadius);
    // path.arcToPoint(
    //   Offset(size.width, size.height / 3 - notchRadius),
    //   radius: Radius.circular(notchRadius),
    // );
    path.lineTo(size.width, cornerRadius);

    // Top-right rounded corner
    path.arcToPoint(
      Offset(size.width - cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Close the path
    path.lineTo(cornerRadius, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
