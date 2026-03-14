import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class WelcomeHeader extends StatefulWidget {
  final void Function(String query) onSearch;

  const WelcomeHeader({
    super.key,
    required this.onSearch,
  });

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  bool _searching = false;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _ctrl.clear();
        widget.onSearch('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Top row ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    'Welcome back ',
                    style: TextStyle(
                      color:      AppTheme.kTextGray,
                      fontSize:   14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text('👋', style: TextStyle(fontSize: 14)),
                ]),
                const SizedBox(height: 2),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text:  'QR',
                        style: TextStyle(
                          color:      AppTheme.kPrimary,
                          fontSize:   26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text:  'Craft',
                        style: TextStyle(
                          color:      AppTheme.kTextDark,
                          fontSize:   26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action icons
            Row(children: [
              _IconBtn(
                icon:   _searching
                    ? Icons.close_rounded
                    : Icons.search_rounded,
                onTap:  _toggleSearch,
                active: _searching,
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon:  Icons.notifications_rounded,
                onTap: () {},
                badge: true,
              ),
            ]),
          ],
        ),

        // ── Search bar ────────────────────────────────────────────
        AnimatedCrossFade(
          duration:     const Duration(milliseconds: 300),
          crossFadeState: _searching
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild:  const SizedBox(height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              height:     48,
              decoration: BoxDecoration(
                color:        AppTheme.kCardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.kBorderColor),
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset:     const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller:  _ctrl,
                autofocus:   true,
                onChanged:   widget.onSearch,
                style: const TextStyle(
                  color:    AppTheme.kTextDark,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText:  'Search saved QR codes...',
                  hintStyle: TextStyle(
                    color:    AppTheme.kTextGray.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.kPrimary,
                    size:  20,
                  ),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _ctrl.clear();
                      widget.onSearch('');
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.kTextGray,
                      size:  18,
                    ),
                  )
                      : null,
                  border:         InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final bool         badge;
  final bool         active;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.badge  = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width:  42,
            height: 42,
            decoration: BoxDecoration(
              color:        active
                  ? AppTheme.kPrimary.withValues(alpha: 0.1)
                  : AppTheme.kCardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset:     const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon,
                color: active
                    ? AppTheme.kPrimary
                    : AppTheme.kTextDark,
                size: 20),
          ),
          if (badge)
            Positioned(
              right: 8,
              top:   8,
              child: Container(
                width:  8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE85D75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}