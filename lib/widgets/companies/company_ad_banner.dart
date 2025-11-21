import 'package:flutter/material.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyAdBanner extends StatelessWidget {
  const CompanyAdBanner({super.key});

  void _openWhatsApp() async {
    const url = 'https://wa.me/584247171773?text=Hola,%20quiero%20m%C3%A1s%20informaci%C3%B3n';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openWhatsApp,
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        width: double.infinity,
        height: responsiveValue(
          context,
          mobile: 200,
          tablet: 300,
        ), // puedes ajustar según necesites
        margin: responsiveValue<EdgeInsets>(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/banner-companies.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
