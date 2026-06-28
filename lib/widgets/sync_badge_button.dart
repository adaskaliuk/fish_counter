import 'package:flutter/material.dart';

class SyncBadgeButton extends StatelessWidget {
  const SyncBadgeButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.isLoading = false,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.cloud_queue,
                  size: 32,
                  color: Colors.orangeAccent,
                ),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Icon(
                    Icons.circle,
                    size: 9,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
    );
  }
}
