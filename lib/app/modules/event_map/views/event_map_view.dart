import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import '../controllers/event_map_controller.dart';

class EventMapView extends GetView<EventMapController> {
  const EventMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(EventMapController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.scaffoldbg,
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            elevation: 0,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Event Map',
                style: AppFont.heading.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(color: AppColors.scaffoldbg),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Map Selector
                _buildMapSelector(),
                const SizedBox(height: 24),
                // Map Viewer
                _buildMapViewer(),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Row(
          children: List.generate(controller.maps.length, (index) {
            final isSelected = controller.selectedMapIndex.value == index;
            return GestureDetector(
              onTap: () => controller.changeMap(index),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.appbarbg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  controller.maps[index]['title']!,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMapViewer() {
    return Obx(
      () => Container(
        height: Get.height * 0.6,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.appbarbg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.asset(
                  controller.maps[controller.selectedMapIndex.value]['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Map not found',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Hint Overlay
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.pinch_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Pinch to Zoom',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
