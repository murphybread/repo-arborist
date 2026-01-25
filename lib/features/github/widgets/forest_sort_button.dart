import 'package:flutter/material.dart';
import 'package:repo_arborist/features/github/models/repository_sort_type_model.dart';

/// Sort button with popup menu for repository sorting
class ForestSortButton extends StatelessWidget {
  final RepositorySortType currentSortType;
  final Function onSortChanged;

  const ForestSortButton({
    required this.currentSortType,
    required this.onSortChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RepositorySortType>(
      icon: const Icon(
        Icons.sort,
        color: Color(0xFF14B8A6),
        size: 20,
      ),
      tooltip: 'Sort repositories',
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0x1AFFFFFF),
        ),
      ),
      offset: const Offset(0, 40),
      onSelected: (RepositorySortType value) {
        onSortChanged(value);
      },
      itemBuilder: (BuildContext context) {
        // Loop through all enum values
        return RepositorySortType.values.map((sortType) {
          // Check if this option is currently selected
          final isSelected = currentSortType == sortType;

          return PopupMenuItem<RepositorySortType>(
            value: sortType,
            child: Row(
              children: [
                Icon(
                  sortType.icon,
                  size: 16,
                  color: isSelected
                      ? const Color(0xFF14B8A6)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 12),
                Text(
                  sortType.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF14B8A6)
                        : const Color(0xFFFFFFFF),
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF14B8A6),
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
