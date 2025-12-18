import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/app_colors.dart';


class HomeHeader extends StatelessWidget {
  final String title;

  const HomeHeader({super.key, required this.title});

  static const _backgroundColor = AppColors.headerBackground;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _backgroundColor, // ANDROID
        statusBarIconBrightness: Brightness.dark, // iconos negros
        statusBarBrightness: Brightness.light, // iOS
      ),
      child: Container(
        color: _backgroundColor,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 12, // 👈 respeta notch
          bottom: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
