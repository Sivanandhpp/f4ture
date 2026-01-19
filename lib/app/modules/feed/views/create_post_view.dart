import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../../core/constants/app_colors.dart';
import 'post_caption_view.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  // Gallery State
  List<AssetPathEntity> albums = [];
  AssetPathEntity? selectedAlbum;
  List<AssetEntity> assets = [];
  AssetEntity? selectedAsset;
  File? selectedFile;

  // Video Player for Preview
  VideoPlayerController? _videoController;
  bool isVideo = false;

  // Pagination
  bool isLoading = false;
  int currentPage = 0;
  final ScrollController scrollController = ScrollController();

  // Colors
  static const Color kBackground = Colors.black;
  static const Color kSurface = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _requestPermission();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _disposeVideoController();
    super.dispose();
  }

  void _disposeVideoController() {
    _videoController?.dispose();
    _videoController = null;
  }

  void _onScroll() {
    if (scrollController.position.pixels /
            scrollController.position.maxScrollExtent >
        0.33) {
      if (!isLoading) {
        _loadAssets();
      }
    }
  }

  Future<void> _requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      _loadAlbums();
    } else {
      Get.snackbar(
        'Permission Denied',
        'Please enable gallery access in settings',
      );
      openAppSettings();
    }
  }

  Future<void> _loadAlbums() async {
    setState(() => isLoading = true);
    // Request type: Common (Video + Image)
    final List<AssetPathEntity> albumList = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albumList.isNotEmpty) {
      setState(() {
        albums = albumList;
        selectedAlbum = albumList[0];
      });
      _loadAssets(refresh: true);
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadAssets({bool refresh = false}) async {
    if (selectedAlbum == null) return;
    if (refresh) {
      assets = [];
      currentPage = 0;
    }

    final List<AssetEntity> pageAssets = await selectedAlbum!.getAssetListPaged(
      page: currentPage,
      size: 60,
    );

    if (pageAssets.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      assets.addAll(pageAssets);
      currentPage++;
      isLoading = false;
      // Auto select first asset if none selected
      if (assets.isNotEmpty && selectedAsset == null) {
        _selectAsset(assets[0]);
      }
    });
  }

  Future<void> _selectAsset(AssetEntity asset) async {
    if (selectedAsset == asset) return;

    // Cleanup previous video if any
    if (isVideo) {
      _disposeVideoController();
    }

    final file = await asset.file;
    if (file == null) return;

    setState(() {
      selectedAsset = asset;
      selectedFile = file;
      isVideo = asset.type == AssetType.video;
    });

    if (isVideo) {
      _videoController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
          _videoController?.setLooping(true);
        });
    }
  }

  Future<void> _onNext() async {
    if (selectedFile == null) return;

    File finalFile = selectedFile!;

    // If video, pause it
    if (isVideo) {
      _videoController?.pause();
    }

    // If image, Crop it!
    if (!isVideo) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: finalFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true, // Force 4:5
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        finalFile = File(croppedFile.path);
      } else {
        // User cancelled crop
        return;
      }
    }

    // Go to Caption View
    Get.to(() => PostCaptionView(file: finalFile, isVideo: isVideo));
  }

  Future<void> _changeAlbum(AssetPathEntity? album) async {
    if (album == null || album == selectedAlbum) return;
    setState(() {
      selectedAlbum = album;
      selectedAsset = null;
      selectedFile = null;
    });
    _disposeVideoController();
    _loadAssets(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: kBackground,
        elevation: 0,
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: selectedFile != null ? _onNext : null,
            child: const Text(
              'Next',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Preview Area (Half Screen)
          Container(
            height: MediaQuery.of(context).size.width * 1.25, // 4:5 Aspectish
            width: double.infinity,
            color: kSurface,
            child: _buildPreview(),
          ),

          // 2. Toolbar (Album Selector + Camera)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: kBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<AssetPathEntity>(
                    value: selectedAlbum,
                    dropdownColor: kSurface,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    items: albums.map((album) {
                      return DropdownMenuItem(
                        value: album,
                        child: Text(
                          album.name,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _changeAlbum,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement Camera
                    Get.snackbar('Camera', 'Camera feature coming soon');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Grid View
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return GestureDetector(
                  onTap: () => _selectAsset(asset),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail
                      Image(
                        image: AssetEntityImageProvider(
                          asset,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize.square(200),
                        ),
                        fit: BoxFit.cover,
                      ),

                      // Video Indicator
                      if (asset.type == AssetType.video)
                        const Positioned(
                          bottom: 4,
                          right: 4,
                          child: Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),

                      // Selected Overlay
                      if (selectedAsset == asset)
                        Container(color: Colors.white.withOpacity(0.4)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (selectedFile == null) {
      return const Center(
        child: Text('Select media', style: TextStyle(color: Colors.grey)),
      );
    }

    if (isVideo) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      return Image.file(
        selectedFile!,
        fit: BoxFit.cover,
        // Note: Actual cropping happens on "Next".
        // Displaying "cover" here simulates the 4:5 crop.
      );
    }
  }
}
