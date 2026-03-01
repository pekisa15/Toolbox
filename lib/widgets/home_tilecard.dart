import 'package:flutter/material.dart';

class HomeTileCard extends StatelessWidget {
  final String title;
  final String imageAssetPath;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const HomeTileCard({
    super.key,
    required this.title,
    required this.imageAssetPath,
    required this.isFavorite,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themedImageAssetPath = isDark ? imageAssetPath.replaceFirst('.png', '_white.png') : imageAssetPath;

    return Card(
      elevation: 3,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isFavorite ? Icons.star : null,
                color: isFavorite ? Colors.amber[800] : null,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.asset(
                    height: 40,
                    themedImageAssetPath,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}