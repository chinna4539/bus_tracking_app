import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/search_result.dart';
import '../providers/bus_data_provider.dart';

typedef SearchResultTapCallback = void Function(SearchResult result);

class _SearchSheetContent extends StatefulWidget {
  const _SearchSheetContent({
    required this.provider,
    required this.onResultSelected,
  });

  final BusDataProvider provider;
  final SearchResultTapCallback onResultSelected;

  @override
  State<_SearchSheetContent> createState() => _SearchSheetContentState();
}

class _SearchSheetContentState extends State<_SearchSheetContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.provider.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.provider.searchQuery;
    final results = widget.provider.searchResults;
    final recent = widget.provider.recentSearches;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(77),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search buses, routes, or stops',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                widget.provider.updateSearchQuery(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            if (query.isEmpty)
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Recent searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (recent.isEmpty)
                      Text(
                        'Your recent searches will appear here.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: recent
                            .map(
                              (entry) => ActionChip(
                                label: Text(entry),
                                onPressed: () {
                                  widget.provider.updateSearchQuery(entry);
                                  setState(() {});
                                },
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (itemContext, index) {
                    final result = results[index];
                    return InkWell(
                      onTap: () {
                        widget.provider.addRecentSearch(result.title);
                        Navigator.of(context).pop();
                        widget.onResultSelected(result);
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(31),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                result.type == SearchResultType.bus
                                    ? Icons.directions_bus_rounded
                                    : result.type ==
                                          SearchResultType.route
                                    ? Icons.route_rounded
                                    : Icons.location_on_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    result.subtitle,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

Future<void> showSearchSheet({
  required BuildContext context,
  required BusDataProvider provider,
  required SearchResultTapCallback onResultSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _SearchSheetContent(
        provider: provider,
        onResultSelected: onResultSelected,
      );
    },
  );
}
