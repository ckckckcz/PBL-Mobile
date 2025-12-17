import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../theme/app_typography.dart';

class TipsListWidget extends StatelessWidget {
  const TipsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      TipItem(
        imagePath: 'assets/images/tips/id_1.svg',
        text: 'Pilah sampah untuk memudahkan daur ulang',
      ),
      TipItem(
        imagePath: 'assets/images/tips/id_2.svg',
        text: 'Ganti bungkus sampah plastik sebelum dibuang',
      ),
      TipItem(
        imagePath: 'assets/images/tips/id_3.svg',
        text: 'Ubah sampah organik jadi kompos',
      ),
      TipItem(
        imagePath: 'assets/images/tips/id_4.svg',
        text: 'Kurangi barang sekali pakai',
      ),
      TipItem(
        imagePath: 'assets/images/tips/id_5.svg',
        text: 'Gunakan ulang wadah yang masih layak',
      ),
    ];

    return Column(
      spacing: 12,
      children: tips.map((tip) => _buildTipItem(tip)).toList(),
    );
  }

  Widget _buildTipItem(TipItem tip) {
    return Container(
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral[50],
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              tip.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Text(
              tip.text,
              style: AppTypography.bodyMediumRegular.copyWith(
                color: AppColors.neutral[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TipItem {
  final String imagePath;
  final String text;

  TipItem({
    required this.imagePath,
    required this.text,
  });
}
