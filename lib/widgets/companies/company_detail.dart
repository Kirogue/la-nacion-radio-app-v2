import 'package:flutter/material.dart';
import 'package:la_nacion/config/text_styles.dart';
import '../../dashboard/models/wp_api_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/media_card.dart';
import '../../config/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _LinkTile extends StatelessWidget {
  final String label;
  final String url;
  final String iconPath;

  const _LinkTile({required this.label, required this.url, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white.withAlpha(100)),
        onTap: () async {
          final uri = Uri.parse(url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          }
        },
      ),
    );
  }
}

class CompanyDetailView extends StatelessWidget {
  final WpItem company;

  const CompanyDetailView({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final acf = company.acf;
    final imgUrl = acf['company_image']?['url'] ?? '';
    final field = (acf['company_field'] is Map ? acf['company_field']['label'] : acf['company_field'] ?? '') as String;

    // Nuevo: company_schedule puede venir como List (repeater) o como String (viejo)
    final scheduleData = acf['company_schedule'] ?? acf['company_schedule_text'] ?? '';

    // Nuevo: company_urls es un group con subfields
    final companyUrls = acf['company_urls'] ?? {};
    final web = (companyUrls['company_url_web'] ?? acf['company_url_web'] ?? '') as String;
    final whatsapp =
        (companyUrls['company_url_whatsapp'] ?? acf['company_url_whatsapp'] ?? '') as String;
    final instagram =
        (companyUrls['company_url_instagram'] ?? acf['company_url_instagram'] ?? '') as String;

    String extractDomain(String url) {
      try {
        final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
        return uri.host.replaceFirst('www.', '');
      } catch (e) {
        return url;
      }
    }

    String extractWhatsAppNumber(String url) {
      if (url.isEmpty) return 'WhatsApp';
      // Try several patterns: api.whatsapp.com/send?phone=549..., wa.me/549..., phone=...
      final patterns = [
        RegExp(r'phone=(\d{7,15})'),
        RegExp(r'wa\.me/(\d{7,15})'),
        RegExp(r'api\.whatsapp\.com/send\?phone=(\d{7,15})'),
        RegExp(r'/?(\+?\d{7,15})$'), // fallback: trailing numbers
      ];
      for (var re in patterns) {
        final match = re.firstMatch(url);
        if (match != null && match.groupCount >= 1) {
          String number = match.group(1)!;
          // Normalize: ensure + and spacing for readability
          if (!number.startsWith('+')) {
            number = '+$number';
          }
          // Example special formatting for VE (58) like tenías antes
          if (number.startsWith('+58') && number.length >= 4) {
            final n = number.substring(1); // remove +
            if (n.length >= 12) {
              return '+${n.substring(0, 2)} ${n.substring(2, 5)}-${n.substring(5, 8)}-${n.substring(8)}';
            }
          }
          return number;
        }
      }
      return 'WhatsApp';
    }

    String extractInstagramHandle(String url) {
      if (url.isEmpty) return 'Instagram';
      final regex = RegExp(r'instagram\.com/([^/?#]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        return '@${match.group(1)}';
      }
      // fallback: if user passed just a handle
      if (url.startsWith('@')) return url;
      return 'Instagram';
    }

    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          iconSize: 32,
          color: AppConstants.textLight,
          onPressed: () => Navigator.pop(context),
        ),

        if (imgUrl.isNotEmpty)
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300),
              child: AspectRatio(
                aspectRatio: 1,
                child: MediaCard(imageUrl: imgUrl, onTap: () {}, xMargin: 0),
              ),
            ),
          ),

        Center(
          child: Text(
            company.title.toUpperCase(),
            style: AppTextStyles.musicTitle.copyWith(fontSize: 32),
          ),
        ),
        Center(child: CategoryLabel(text: field.toUpperCase())),

        Column(
          spacing: 5,
          children: [
            if (web.isNotEmpty)
              _LinkTile(label: extractDomain(web), url: web, iconPath: 'assets/icons/web.svg'),
            if (whatsapp.isNotEmpty)
              _LinkTile(
                label: extractWhatsAppNumber(whatsapp),
                url: whatsapp,
                iconPath: 'assets/icons/whatsapp.svg',
              ),
            if (instagram.isNotEmpty)
              _LinkTile(
                label: extractInstagramHandle(instagram),
                url: instagram,
                iconPath: 'assets/icons/instagram.svg',
              ),

            // ScheduleCard ahora recibe datos estructurados o string antiguo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ScheduleCard(scheduleData: scheduleData),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
