import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../model/saved_collage.dart';

class ViewCollagesScreen extends StatefulWidget {
  final List<SavedCollage> collagesList;
  final int initialIndex;

  const ViewCollagesScreen({
    Key? key,
    required this.collagesList,
    required this.initialIndex,
  }) : super(key: key);

  static Route route(List<SavedCollage> items, int currentIndex) {
    return MaterialPageRoute<void>(
      builder: (context) => ViewCollagesScreen(
        collagesList: items, 
        initialIndex: currentIndex,
      ),
    );
  }

  @override
  State<ViewCollagesScreen> createState() => _ViewCollagesScreenState();
}

class _ViewCollagesScreenState extends State<ViewCollagesScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPreviousPage() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentIndex < widget.collagesList.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.collagesList[_currentIndex].name,
          style: AppTextStyles.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${widget.collagesList.length}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.collagesList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.collagesList[index];
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'collage_image_${item.imagePath}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(item.imagePath),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context).name,
                        style: AppTextStyles.imageTitle,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_album, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.name,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context).description,
                          style: AppTextStyles.imageTitle,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.description,
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context).tagsLabel,
                        style: AppTextStyles.imageTitle,
                      ),
                      const SizedBox(height: 8),
                      item.tags.isNotEmpty
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: item.tags
                                  .map((tag) => Chip(
                                        label: Text(tag),
                                        backgroundColor:
                                            AppColors.border.withValues(alpha: 51),
                                        labelStyle: const TextStyle(color: AppColors.primary),
                                      ))
                                  .toList(),
                            )
                          : Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.label_off_outlined,
                                      color: Colors.grey),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.of(context).noTags,
                                    style: AppTextStyles.body
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }
          ),
          
          if (widget.collagesList.length > 1) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _currentIndex > 0 
                ? _buildNavigationButton(
                    icon: Icons.chevron_left,
                    onTap: _goToPreviousPage,
                    alignment: Alignment.centerLeft,
                  )
                : const SizedBox(width: 50),
            ),
            
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _currentIndex < widget.collagesList.length - 1
                ? _buildNavigationButton(
                    icon: Icons.chevron_right,
                    onTap: _goToNextPage,
                    alignment: Alignment.centerRight,
                  )
                : const SizedBox(width: 50),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required AlignmentGeometry alignment,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        color: Colors.transparent,
        alignment: alignment,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 150),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
