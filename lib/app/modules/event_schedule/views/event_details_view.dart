import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:f4ture/app/core/constants/app_colors.dart';
import 'package:f4ture/app/core/constants/app_styles.dart';
import 'package:f4ture/app/data/models/event_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsView extends StatelessWidget {
  final EventModel event;

  const EventDetailsView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldbg, // Dark background
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 4:5 Image Header
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 24,
                    ), // Space for card overlap
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: event.imageUrl != null
                        ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.event,
                              size: 80,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Info Card (Floating Effect)
            Transform.translate(
              offset: const Offset(0, -60), // Overlap with image
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.appbarbg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: AppFont.heading.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      event.startTime != null
                                          ? DateFormat(
                                              'd MMM yyyy',
                                            ).format(event.startTime!)
                                          : 'Date TBA',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      event.startTime != null
                                          ? (event.endTime != null
                                                ? '${DateFormat('h:mm a').format(event.startTime!)} - ${DateFormat('h:mm a').format(event.endTime!)}'
                                                : DateFormat(
                                                    'h:mm a',
                                                  ).format(event.startTime!))
                                          : 'Time TBA',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        event.venue,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Price Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  event.ticketPrice > 0
                                      ? '${event.currency}'
                                      : 'Free',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (event.ticketPrice > 0)
                                  Text(
                                    '${event.ticketPrice.toInt()}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. About Section
            Transform.translate(
              offset: const Offset(0, -40), // Adjust for the overlap above
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Event',
                      style: AppFont.heading.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20), // Bottom padding
                    // 4. Map Section (Conditional)
                    Builder(
                      builder: (context) {
                        final mapData = _getMapForVenue(event.venue);
                        if (mapData == null) return const SizedBox.shrink();
                        return _buildMapSection(context, mapData);
                      },
                    ),
                    const SizedBox(height: 100), // Bottom padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.all(16) +
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: AppColors.appbarbg,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Buy Ticket Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (event.ticketPurchaseUrl != null &&
                        event.ticketPurchaseUrl!.isNotEmpty) {
                      launchUrl(Uri.parse(event.ticketPurchaseUrl!));
                    } else {
                      Get.snackbar(
                        'Info',
                        'Ticket booking not available online.',
                        backgroundColor: Colors.white10,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Buy Ticket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appbaritems,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _getMapForVenue(String venue) {
    final v = venue.toLowerCase().replaceAll(' ', '');
    // Kinfra Venues: keys + likely values
    if ([
      'alphahall',
      'betabay',
      'expo',
      'alphahall',
      'betabay',
      'kinfraexpocentre',
    ].contains(v)) {
      return {
        'title': 'Kinfra',
        'image': 'assets/images/kinfra.png',
        'aspectRatio': 1.0,
        'mapLink': 'https://maps.app.goo.gl/GMj73tK4M7ZQQrV69',
        'Address':
            'KINFRA International Exhibition cum Convention Centre, Infopark, Kakkanad, Kochi',
        'locationImg': 'assets/images/kinfra_location.png',
      };
    }
    // Campus Venues: keys + likely values
    if ([
      'gamma1',
      'gamma2',
      'genx',
      'geny',
      'jaincampus',
      'gamma1',
      'gamma2',
      'genx',
      'geny',
      'jaincampus',
    ].contains(v)) {
      return {
        'title': 'Campus',
        'image': 'assets/images/campus.png',
        'aspectRatio': 1.0,
        'mapLink': 'https://maps.app.goo.gl/3kEkaFTCskauVEit6',
        'Address':
            'JAIN (Deemed-to-be University), Knowledge Park, Infopark, Kakkanad, Kochi',
        'locationImg': 'assets/images/campus_location.png',
      };
    }
    return null;
  }

  Widget _buildMapSection(BuildContext context, Map<String, dynamic> mapData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Location Map',
          style: AppFont.heading.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        // Map Viewer
        AspectRatio(
          aspectRatio: mapData['aspectRatio'] as double,
          child: Container(
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
                      mapData['image'] as String,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Zoom',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Location Card
        GestureDetector(
          onTap: () async {
            if (mapData['mapLink'] != null) {
              final Uri url = Uri.parse(mapData['mapLink'] as String);
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                Get.snackbar('Error', 'Could not launch Maps');
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.appbarbg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (mapData.containsKey('locationImg'))
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(mapData['locationImg'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mapData['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mapData['Address'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions,
                            color: AppColors.primary,
                            size: 16,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
