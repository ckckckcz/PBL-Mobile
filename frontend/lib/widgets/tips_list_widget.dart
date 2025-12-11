import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';

class TipsListWidget extends StatelessWidget {
  const TipsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      TipItem(
        icon: PhosphorIcons.recycle(PhosphorIconsStyle.regular),
        iconColor: const Color(0xFF66BB6A),
        text: 'Pilah sampah untuk memudahkan daur ulang',
      ),
      TipItem(
        icon: PhosphorIcons.shoppingCart(PhosphorIconsStyle.regular),
        iconColor: const Color(0xFF42A5F5),
        text: 'Ganti bungkus sampah plastik sebelum dibuang',
      ),
      TipItem(
        icon: PhosphorIcons.package(PhosphorIconsStyle.regular),
        iconColor: const Color(0xFF26A69A),
        text: 'Ubah sampah organik jadi kompos',
      ),
      TipItem(
        icon: PhosphorIcons.shoppingBag(PhosphorIconsStyle.regular),
        iconColor: const Color(0xFFFF7043),
        text: 'Kurangi barang sekali pakai',
      ),
      TipItem(
        icon: PhosphorIcons.coins(PhosphorIconsStyle.regular),
        iconColor: const Color(0xFFFFCA28),
        text: 'Gunakan ulang wadah yang masih layak',
      ),
    ];

    return Column(
      children: tips.map((tip) => _buildTipItem(tip)).toList(),
    );
  }

  Widget _buildTipItem(TipItem tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tip.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              tip.icon,
              color: tip.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
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
  final IconData icon;
  final Color iconColor;
  final String text;

  TipItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });
}