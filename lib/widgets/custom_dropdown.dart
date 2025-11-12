import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// CustomDropdown - 드롭다운 선택 위젯
///
/// 기능:
/// - 선택 항목 표시
/// - 드롭다운 메뉴 펼치기/접기
/// - 선택된 항목 강조
/// - 그림자 효과
/// - 반응형 디자인
class CustomDropdown extends StatefulWidget {
  final String placeholder;
  final List<String> items;
  final String? selectedItem;
  final Function(String) onChanged;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  const CustomDropdown({
    Key? key,
    required this.placeholder,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.margin,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isExpanded = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: appTheme.white_A700,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.borderRadius ?? 20.h),
                  bottomRight: Radius.circular(widget.borderRadius ?? 20.h),
                ),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.color66D3D3,
                    offset: Offset(0, 4.h),
                    blurRadius: 8.h,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.map((item) {
                  bool isLast = item == widget.items.last;
                  return _buildDropdownItem(item, isLast);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(String item, bool isLast) {
    bool isSelected = item == widget.selectedItem;

    return InkWell(
      onTap: () {
        widget.onChanged(item);
        _removeOverlay();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 9.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: isLast
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(widget.borderRadius ?? 20.h),
                  bottomRight: Radius.circular(widget.borderRadius ?? 20.h),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item,
              style: TextStyleHelper.instance.body14RegularPretendard.copyWith(
                color: isSelected ? appTheme.gray_800 : Color(0xFF797979),
              ),
            ),
            if (isSelected)
              Container(
                width: 18.h,
                height: 18.h,
                decoration: BoxDecoration(
                  color: appTheme.green_50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 12.h,
                    color: appTheme.teal_400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        margin: widget.margin,
        child: InkWell(
          onTap: _toggleDropdown,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 9.h),
            decoration: BoxDecoration(
              color: appTheme.white_A700,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 20.h),
              boxShadow: [
                BoxShadow(
                  color: appTheme.color66D3D3,
                  offset: Offset(0, 4.h),
                  blurRadius: 8.h,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedItem ?? widget.placeholder,
                  style: TextStyleHelper.instance.body14RegularPretendard
                      .copyWith(
                    color: widget.selectedItem != null
                        ? appTheme.gray_800
                        : appTheme.blue_gray_100,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: appTheme.teal_400,
                  size: 24.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
