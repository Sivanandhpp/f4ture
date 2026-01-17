import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import '../controllers/event_map_controller.dart';

import 'package:url_launcher/url_launcher.dart';

class EventMapView extends GetView<EventMapController> {
  const EventMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(EventMapController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldbg,
      body: Obx(
        () => CustomScrollView(
          physics: controller.isInteractingWithMap.value
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
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
                  const SizedBox(height: 24),
                  // Location Info
                  _buildLocationInfo(),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
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
                    color: isSelected
                        ? AppColors.appbaritems
                        : AppColors.appbaritems.withOpacity(0.7),
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
    return Obx(() {
      final currentMap = controller.maps[controller.selectedMapIndex.value];
      return AspectRatio(
        aspectRatio: currentMap['aspectRatio'],
        child: Container(
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
                  maxScale: 4.0, // Increased zoom for image details
                  onInteractionStart: (_) {
                    controller.isInteractingWithMap.value = true;
                  },
                  onInteractionEnd: (_) {
                    controller.isInteractingWithMap.value = false;
                  },
                  child: Image.asset(
                    currentMap['image']!,
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
    });
  }

  Widget _buildLocationInfo() {
    return Obx(() {
      final currentMap = controller.maps[controller.selectedMapIndex.value];

      // If Common is selected, show both locations (Campus & Kinfra)
      if (currentMap['title'] == 'Common') {
        return Column(
          children: [
            // Filter other maps that have location data
            ...controller.maps
                .where(
                  (map) =>
                      map['title'] != 'Common' && map.containsKey('mapLink'),
                )
                .map((map) => _buildLocationCard(map)),
          ],
        );
      } else {
        // Show specific location info
        return _buildLocationCard(currentMap);
      }
    });
  }

  Widget _buildLocationCard(Map<String, dynamic> mapWithLocation) {
    if (!mapWithLocation.containsKey('mapLink')) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        if (mapWithLocation['mapLink'] != null) {
          final Uri url = Uri.parse(mapWithLocation['mapLink']);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            Get.snackbar('Error', 'Could not launch Maps');
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.appbarbg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Location Image
            if (mapWithLocation.containsKey('locationImg'))
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(mapWithLocation['locationImg']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mapWithLocation['title'] ?? 'Venue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mapWithLocation['Address'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      if (mapWithLocation['mapLink'] != null) {
                        final Uri url = Uri.parse(mapWithLocation['mapLink']);
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          Get.snackbar('Error', 'Could not launch Maps');
                        }
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Get Directions',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
