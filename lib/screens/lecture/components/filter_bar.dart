import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final Function(String) onSearchChanged;
  final List<String> statusOptions;

  const FilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onSearchChanged,
    required this.statusOptions,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search lectures...'.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.cardColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: widget.selectedStatus,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(12),
            onChanged: (newValue) {
              if (newValue != null) widget.onStatusChanged(newValue);
            },
            items: widget.statusOptions
                .map<DropdownMenuItem<String>>((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
