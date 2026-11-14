import 'package:flutter/material.dart';
import '../theme/dark_color_mapper.dart';
import '../theme/karsa_theme.dart';

class ChartRow extends StatelessWidget {
  final String label;
  final double count;
  final double total;
  final Color color;
  final String? display;

  const ChartRow({
    super.key,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    this.display,
  });

  @override
  Widget build(BuildContext context) {
    final theme = KarsaThemeScope.of(context);
    final c = theme.colors;
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final trackBg = DarkColorMapper.surface(
      const Color(0xFFF3E7E6),
      isDark: c.isDark,
    );
    final shownText = display ??
        (count == count.roundToDouble() ? count.toInt().toString() : count.toString());

    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 58,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 10,
                color: trackBg,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 30,
            child: Text(
              shownText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: c.ink,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
