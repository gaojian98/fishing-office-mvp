import 'package:flutter/material.dart';

import '../core/app_color.dart';
import '../core/app_typography.dart';
import '../models/routes_config.dart';

class JsonRoutePage extends StatelessWidget {
  const JsonRoutePage({
    super.key,
    required this.route,
  });

  final AppRoute route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackground,
      appBar: AppBar(
        title: Text(route.page),
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: DefaultTextStyle(
            style: AppTypography.body,
            textAlign: TextAlign.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  route.page,
                  style: AppTypography.h2,
                ),
                const SizedBox(height: 12),
                Text('path: ${route.path}'),
                Text('type: ${route.type}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
