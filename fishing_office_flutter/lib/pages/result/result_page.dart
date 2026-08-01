import 'package:flutter/material.dart';

import '../../core/app_color.dart';
import '../../core/app_typography.dart';
import '../../core/buttons/fishing_buttons.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('结果', style: AppTypography.h1)),
                  FishingIconButton(
                    iconId: 'icon_back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('结果页保留为独立路由，占位等待后续接入。', style: AppTypography.body),
              const SizedBox(height: 12),
              Text('当前 MVP 不新增玩法。', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}
