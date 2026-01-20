import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final TextEditingController? searchController;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    required this.title,
    this.searchHint,
    this.onSearchChanged,
    this.onSearchClear,
    this.searchController,
    this.actions,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _searchController;
  bool _isSearchExpanded = false;
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _searchController.addListener(_onSearchTextChanged);
    _hasSearchText = _searchController.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    } else {
      _searchController.removeListener(_onSearchTextChanged);
    }
    super.dispose();
  }

  void _onSearchTextChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (hasText != _hasSearchText) {
      setState(() {
        _hasSearchText = hasText;
      });
    }
    widget.onSearchChanged?.call(_searchController.text);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        widget.onSearchClear?.call();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: _isSearchExpanded
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'بحث...',
                hintStyle: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )
          : Text(widget.title, style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
      actions: [
        // Search icon button (minimized)
        if (!_isSearchExpanded)
          IconButton(
            icon: Icon(
              UIcons.regularRounded.search,
              color: colorScheme.onSurface,
              size: 20,
            ),
            onPressed: _toggleSearch,
            tooltip: 'بحث',
          ),
        // Clear/Cancel button when search is expanded
        if (_isSearchExpanded) ...[
          if (_hasSearchText)
            IconButton(
              icon: Icon(
                UIcons.regularRounded.x,
                color: colorScheme.onSurface,
              ),
              onPressed: _clearSearch,
              tooltip: 'مسح',
            ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: colorScheme.onSurface,
            ),
            onPressed: _toggleSearch,
            tooltip: 'إلغاء',
          ),
        ],
        // Additional actions
        ...?widget.actions,
          SizedBox(width: 8),
      ],
    );
  }
}

