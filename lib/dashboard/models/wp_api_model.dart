import 'package:html_unescape/html_unescape.dart';

class WpItem {
  final int id;
  final String title;
  final Map<String, dynamic> acf;

  WpItem({required this.id, required this.title, required this.acf});

  factory WpItem.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();

    return WpItem(id: json['id'], title: unescape.convert(json['title']['rendered'] ?? ''), acf: json['acf'] ?? {});
  }
}
