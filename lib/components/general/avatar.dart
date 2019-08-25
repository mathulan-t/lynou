import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:lynou/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class LYAvatar extends StatelessWidget {
  final double size;

  LYAvatar({
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CacheImage.firebase(
        width: size != null ? size : 60,
        height: size != null ? size : 60,
        fit: BoxFit.cover,
        path: 'avatars/puppy.png',
        placeholder: Container(
          width: size != null ? size : 60,
          height: size != null ? size : 60,
          color: themeProvider.secondBackgroundColor,
        ),
      ),
    );
  }
}
