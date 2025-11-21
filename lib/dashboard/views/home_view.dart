import 'package:flutter/material.dart';
import 'package:la_nacion/dashboard/controllers/companies_controller.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:la_nacion/dashboard/controllers/reels_controller.dart';
import 'package:la_nacion/widgets/content_section.dart';
import 'package:la_nacion/widgets/custom_wrapper.dart';
import 'package:la_nacion/widgets/reels/reels_section.dart';
import 'package:provider/provider.dart';
import 'package:la_nacion/dashboard/controllers/ads_controller.dart';
import 'package:la_nacion/widgets/ad_banner.dart';
import 'package:la_nacion/widgets/radio/live_radio_banner.dart';
import 'package:la_nacion/widgets/media_card.dart';
import 'package:la_nacion/widgets/youtube.dart';
import 'package:la_nacion/utils/responsive_values.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final adsController = Provider.of<AdsController>(context, listen: false);
      if (adsController.items.isEmpty) {
        adsController.fetchItems();
      }

      final newsController = Provider.of<NewsController>(context, listen: false);
      if (newsController.newsList.isEmpty && !newsController.isLoading) {
        newsController.loadNews();
      }

      final reelsController = Provider.of<ReelsController>(context, listen: false);
      if (reelsController.reels.isEmpty && !reelsController.isLoading) {
        reelsController.fetchReels();
      }

      final companiesController = Provider.of<CompaniesController>(context, listen: false);
      if (companiesController.items.isEmpty && !companiesController.isLoading) {
        companiesController.fetchItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final adsController = Provider.of<AdsController>(context);
    final ads = adsController.getUniqueAds(3);
    final moreAds = adsController.getUniqueAds(3);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ContentWrapper(
        child: Column(
          children: [
            LiveRadioBanner(),
            HomeNewsSection(title: 'NOTICIAS DESTACADAS'),
            AdBanner(ads: ads),
            ContentSection(title: 'LA NACION RADIO', routeName: 'radio'),
            InfoCard(
              imageUrl: 'assets/images/enlace-r.png',
              title: 'ENLACE RADIAL',
              icon: Icons.arrow_forward_ios,
              isLocalImage: true,
              height: responsiveValue<double>(context, mobile: 120, tablet: 200),
            ),
            ContentSection(title: 'EMPRESAS DESTACADAS', routeName: 'companies'),
            ReelsSection(),
            Youtube(),
            AdBanner(ads: moreAds),
            // Espacio extra para el navbar
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
