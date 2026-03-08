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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        themedImageAssetPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8.0, left: 4.0, right: 4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontSize: 32),
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