// import 'package:flutter/material.dart';

// class BackCircleButton extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final Color? backgroundColor;
//   final Color? iconColor;
//   final double radius;
//   final double iconSize;

//   const BackCircleButton({
//     super.key,
//     this.onPressed,
//     this.backgroundColor,
//     this.iconColor,
//     this.radius = 20,
//     this.iconSize = 20,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: onPressed ?? () => Navigator.pop(context),
//       icon: CircleAvatar(
//         radius: radius,
//         backgroundColor: backgroundColor ?? Colors.white.withValues(alpha: .5),
//         child: Icon(
//           Icons.arrow_back,
//           color: iconColor ?? Colors.black,
//           size: iconSize,
//         ),
//       ),
//     );
//   }
// }
