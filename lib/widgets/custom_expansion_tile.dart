import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final bool initiallyExpanded;
  final VoidCallback onSelectParent;
  final List<Widget> children;
  final Color? backgroundColor;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.onSelectParent,
    this.children = const <Widget>[],
    this.initiallyExpanded = false,
    this.backgroundColor,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: widget.backgroundColor,
          child: ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            onTap: widget.onSelectParent, // 👈 tocar el título selecciona
            trailing: IconButton(
              icon: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more, color: Colors.white),
              ),
              onPressed: _toggleExpanded, // 👈 tocar el ícono expande/colapsa
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _expanded ? 1 : 0,
            child: _expanded ? Column(children: widget.children) : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
