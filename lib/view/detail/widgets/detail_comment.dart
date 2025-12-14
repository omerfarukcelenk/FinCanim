import 'package:flutter/material.dart';
import 'package:falcim_benim/utils/responsive_size.dart';

class DetailComment extends StatelessWidget {
  final String reading;
  final int? userAge;
  final String? categoryTitle;

  const DetailComment({
    super.key,
    required this.reading,
    this.userAge,
    this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg_pattern.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(ResponsiveSize.radius_16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).shadowColor.withAlpha((0.3 * 255).round()),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: EdgeInsets.all(ResponsiveSize.padding_12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveSize.padding_12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(ResponsiveSize.radius_12),
                ),
                padding: EdgeInsets.all(ResponsiveSize.padding_12),
                child: InteractiveViewer(
                  panEnabled: false,
                  scaleEnabled: true,
                  boundaryMargin: EdgeInsets.zero,
                  minScale: 1.0,
                  maxScale: 2.0,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      reading,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: _computeFontSize(),
                        fontWeight: _computeFontWeight(),
                        color: Theme.of(context).textTheme.titleLarge!.color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _computeFontSize() {
    final base = ResponsiveSize.fontSize_18;
    if (userAge == null) return base;
    if (userAge! > 50) return base + 4; // significantly larger
    if (userAge! > 30) return base + 2; // larger
    return base;
  }

  FontWeight _computeFontWeight() {
    // Default weight
    if (userAge == null) return FontWeight.w400;
    if (userAge! > 50) return FontWeight.w600;
    if (userAge! > 30) return FontWeight.w500;
    return FontWeight.w400;
  }
}
