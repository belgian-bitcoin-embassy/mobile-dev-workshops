import 'package:bitcoin_flutter_app/constants.dart';
import 'package:flutter/material.dart';

class IconLabelStackedButton extends StatelessWidget {
  const IconLabelStackedButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingUnit * 5),
        child: Column(
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(height: kSpacingUnit),
            Text(label),
          ],
        ),
      ),
    );
  }
}
