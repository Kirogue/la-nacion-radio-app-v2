import 'dart:async';
import 'package:flutter/material.dart';
import 'package:la_nacion/config/constants.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:provider/provider.dart';
import 'package:la_nacion/dashboard/controllers/reels_controller.dart';
import 'reel_card.dart';
import 'reel_skeleton_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelsSection extends StatefulWidget {
  const ReelsSection({super.key});

  @override
  State<ReelsSection> createState() => _ReelsSectionState();
}

class _ReelsSectionState extends State<ReelsSection> {
  final _controller = ScrollController();
  int playingIndex = 0;
  bool _isVisible = true;
  bool _isAdvancing = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _controller.offset;

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 80 + MediaQuery.of(context).padding.top;
    final bottomNavHeight = 56 + MediaQuery.of(context).padding.bottom;

    final verticalPaddingContainer = responsiveValue(context, mobile: 8.0, tablet: 32.0);
    final spacingContainer = 20.0;
    final containerHeight =
        (verticalPaddingContainer * 2) +
        spacingContainer +
        40 // Content Container
        ;

    final cardHeight = screenHeight - appBarHeight - bottomNavHeight - containerHeight;
    final cardWidth = (cardHeight * 9 / 16) + 12;

    final idx = (offset / cardWidth).round();
    if (idx != playingIndex) {
      setState(() {
        playingIndex = idx;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible != _isVisible) {
      setState(() {
        _isVisible = visible;
      });
    }
  }

  void _advanceToNextReel() {
    if (!_isVisible || _isAdvancing) return;
    setState(() => _isAdvancing = true);
    final reelsController = Provider.of<ReelsController>(context, listen: false);
    final reels = reelsController.reels.take(6).toList();
    if (reels.isEmpty) return;

    int nextIndex = playingIndex + 1;
    if (nextIndex >= reels.length) nextIndex = 0;

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 80 + MediaQuery.of(context).padding.top;
    final bottomNavHeight = 56 + MediaQuery.of(context).padding.bottom;

    final verticalPaddingContainer = responsiveValue(context, mobile: 8.0, tablet: 32.0);
    final spacingContainer = 20.0;
    final containerHeight =
        (verticalPaddingContainer * 2) +
        spacingContainer +
        40 // Content Container
        ;

    final cardHeight = screenHeight - appBarHeight - bottomNavHeight - containerHeight;
    final cardWidth = cardHeight * 9 / 16;

    _controller
        .animateTo(
          nextIndex * (MediaQuery.of(context).size.width * cardWidth + 12),
          duration: const Duration(milliseconds: 400),
          curve: Curves.ease,
        )
        .then((_) {
          if (mounted) {
            setState(() {
              playingIndex = nextIndex;
              _isAdvancing = false;
            });
          }
        });
  }

  Future<void> openInstagramProfile(String username) async {
    final instagramUri = Uri.parse('instagram://user?username=$username');
    final webUri = Uri.parse('https://instagram.com/$username');

    try {
      final ok = await launchUrl(instagramUri, mode: LaunchMode.externalApplication);
      if (!ok) {
        // Si no abre la app, forzamos abrir en navegador
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Si da error directo, abrimos navegador
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reelsController = Provider.of<ReelsController>(context);
    final reels = reelsController.reels.take(6).toList();
    final isLoading = reelsController.isLoading;

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 80 + MediaQuery.of(context).padding.top;
    final bottomNavHeight = 56 + MediaQuery.of(context).padding.bottom;

    final verticalPaddingContainer = 32.0;
    final spacingContainer = 20.0;
    final containerHeight =
        (verticalPaddingContainer * 2) +
        spacingContainer +
        40 // Content Container
        ;

    final cardHeight = screenHeight - appBarHeight - bottomNavHeight - containerHeight;
    final cardWidth = cardHeight * 9 / 16;

    return VisibilityDetector(
      key: const Key('reels-section'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        margin: responsiveValue<EdgeInsets>(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        ),
        child: Column(
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('REELS SUGERIDOS', style: Theme.of(context).textTheme.titleMedium),
                GestureDetector(
                  onTap: () async {
                    final username = reels.isNotEmpty ? reels.first.username : null;
                    if (username != null) {
                      await openInstagramProfile(username);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'VER MAS',
                          style: TextStyle(
                            color: AppConstants.textLight,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, color: AppConstants.textLight, size: 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacingContainer),

            // LISTA DE REELS
            SizedBox(
              height: cardHeight,
              child: ListView.separated(
                controller: isLoading ? null : _controller,
                scrollDirection: Axis.horizontal,
                itemCount: isLoading ? 6 : reels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return isLoading
                      ? ReelSkeletonCard(height: cardHeight)
                      : ReelCard(
                        reel: reels[index],
                        isPlaying: index == playingIndex && _isVisible,
                        isMuted: _isMuted,
                        onMuteToggle: _toggleMute,
                        height: cardHeight,
                        width: cardWidth,
                        onCompleted: _advanceToNextReel,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
