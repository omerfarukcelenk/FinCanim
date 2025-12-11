import 'dart:io';

import 'package:flutter/material.dart';
import 'package:falcim_benim/utils/responsive_size.dart';

class DetailImages extends StatefulWidget {
  final List<String> imagePaths;

  const DetailImages({super.key, required this.imagePaths});

  @override
  State<DetailImages> createState() => _DetailImagesState();
}

class _DetailImagesState extends State<DetailImages> {
  final PageController _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePaths = widget.imagePaths;
    final hasImage = imagePaths.isNotEmpty && imagePaths.first.isNotEmpty;
    final height = ResponsiveSize.height_200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(ResponsiveSize.radius_16),
            border: Border.all(color: Theme.of(context).dividerColor, width: 2),
          ),
          child: hasImage
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: imagePaths.length,
                  onPageChanged: (idx) => setState(() => _current = idx),
                  itemBuilder: (context, index) {
                    final p = imagePaths[index];
                    final fileExists = p.isNotEmpty && File(p).existsSync();
                    if (!fileExists) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          size: ResponsiveSize.icon_48,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      );
                    }

                    return InteractiveViewer(
                      panEnabled: true,
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(p),
                          width: double.infinity,
                          height: height,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Icon(
                    Icons.local_cafe,
                    size: ResponsiveSize.icon_48,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
        ),
        if (imagePaths.length > 1) ...[
          SizedBox(height: ResponsiveSize.padding_8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              imagePaths.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _current == i ? 12 : 8,
                height: _current == i ? 12 : 8,
                decoration: BoxDecoration(
                  color: _current == i
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).dividerColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
