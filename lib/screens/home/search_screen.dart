import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_scope.dart';
import '../../theme/app_theme.dart';
import '../../utils/geo.dart';

/// Opens the destination search and applies the chosen place to the app state.
Future<void> openDestinationSearch(BuildContext context) async {
  final place = await Navigator.of(context).push<Place>(
    PageRouteBuilder<Place>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondary) =>
          const SearchDestinationScreen(),
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
  if (place != null && context.mounted) {
    AppScope.read(context).setDestination(place);
  }
}

class SearchDestinationScreen extends StatefulWidget {
  const SearchDestinationScreen({super.key});

  @override
  State<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  String _distance(Place p) {
    final km =
        manhattan(MockData.current.grid, p.grid) * MockData.kmPerGridUnit;
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final all = MockData.places;
    final results = q.isEmpty
        ? const <Place>[]
        : all
            .where((p) =>
                p.name.toLowerCase().contains(q) ||
                p.subtitle.toLowerCase().contains(q))
            .toList();
    final saved = all.where((p) => p.id == 'home' || p.id == 'work').toList();
    final popular =
        all.where((p) => p.id != 'home' && p.id != 'work').toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Text(
                    'Where to?',
                    style: context.tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                decoration: BoxDecoration(
                  color: context.cardColor2,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: context.border),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 11,
                          height: 11,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(width: 2, height: 30, color: context.border),
                        Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: context.textStrong,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 46,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                MockData.current.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.muted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: context.border),
                          SizedBox(
                            height: 52,
                            child: TextField(
                              controller: _query,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search destination',
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                suffixIcon: q.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: _query.clear,
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  if (q.isNotEmpty) ...[
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 54,
                              color: context.muted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No places found',
                              style: context.tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try a landmark, station or area name.',
                              style: TextStyle(color: context.muted),
                            ),
                          ],
                        ),
                      )
                    else
                      ...results.map(_tile),
                  ] else ...[
                    _label(context, 'Saved places'),
                    ...saved.map(_tile),
                    const SizedBox(height: 12),
                    _label(context, 'Popular destinations'),
                    ...popular.map(_tile),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: context.muted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _tile(Place p) {
    return Builder(
      builder: (context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pop(p),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.soft,
                  shape: BoxShape.circle,
                ),
                child: Icon(p.icon, size: 22, color: context.cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                _distance(p),
                style: TextStyle(
                  color: context.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
