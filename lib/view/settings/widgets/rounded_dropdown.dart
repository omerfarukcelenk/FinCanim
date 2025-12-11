part of settings_screen;

class RoundedDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const RoundedDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure value is in items, otherwise use first item
    final safeValue = items.contains(value) ? value : items.first;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: safeValue,
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }
}
