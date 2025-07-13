import 'package:flutter/material.dart';

import 'json_widget.dart';
import 'model/json_node.dart';
import 'model/value_type.dart';

class JsonNodeWidget extends StatelessWidget {
  /// The respective index.
  final int index;

  /// The model to build.
  final JsonNode node;

  /// {@template node.hiddenKeys}
  /// Specifies a list of keys whose values are hidden.
  ///
  /// This list is case-insensitive checked.
  /// {@endtemplate}
  final List<String> hiddenKeys;

  /// Called when the node is toggled (pressed).
  final void Function(bool expanded) onToggle;

  /// Called when the user double-taps this node.
  final VoidCallback? onDoubleTap;

  /// Called when the user long-presses this node.
  final VoidCallback? onLongPress;

  /// Specifies the minimum height for this node.
  final double minHeight;

  /// {@template node.nodeIndent}
  /// Horizontal indent multiplier.
  /// {@endtemplate}
  final double nodeIndent;

  /// {@template node.additionalLeafIndent}
  /// Additional horizontal indent for leaf nodes
  /// (child nodes which are not parents themself).
  /// {@endtemplate}
  final double additionalLeafIndent;

  /// Widget used to show when [JsonNode.expanded] is true.
  final Widget expandIcon;

  /// Widget used to show when [JsonNode.expanded] is false.
  final Widget collapseIcon;

  /// {@template node.keyColor}
  /// The color used for the [JsonNode.key] text.
  /// {@endtemplate}
  final Color keyColor;

  /// {@template node.numColor}
  /// The color used for the [JsonNode.value] text
  /// when [JsonNode.type] = [ValueType.num].
  /// {@endtemplate}
  final Color numColor;

  /// {@template node.stringColor}
  /// The color used for the [JsonNode.value] text
  /// when [JsonNode.type] = [ValueType.string].
  /// {@endtemplate}
  final Color stringColor;

  /// {@template node.boolColor}
  /// The color used for the [JsonNode.value] text
  /// when [JsonNode.type] = [ValueType.bool].
  /// {@endtemplate}
  final Color boolColor;

  /// {@template node.arrayColor}
  /// The color used for the [JsonNode.value] text
  /// when [JsonNode.type] = [ValueType.array].
  /// {@endtemplate}
  final Color arrayColor;

  /// {@template node.objectColor}
  /// The color used for the [JsonNode.value] text
  /// when [JsonNode.type] = [ValueType.object].
  /// {@endtemplate}
  final Color objectColor;

  /// {@template node.noneColor}
  /// The color used for the [JsonNode.value] text
  /// when [JsonNode.type] = [ValueType.none].
  /// {@endtemplate}
  final Color noneColor;

  /// {@template node.hiddenColor}
  /// The color used for the container
  /// when this key is specified in [hiddenKeys].
  /// {@endtemplate}
  final Color hiddenColor;

  /// {@template node.hiddenTextColor}
  /// The color used for the "hidden" text
  /// when this key is specified in [hiddenKeys].
  /// {@endtemplate}
  final Color hiddenTextColor;

  /// {@template node.nodeBuilder}
  /// A builder to wrap nodes.
  /// {@endtemplate}
  final JsonNodeWidgetBuilder? nodeBuilder;

  const JsonNodeWidget({
    super.key,
    required this.index,
    required this.node,
    required this.hiddenKeys,
    required this.onToggle,
    this.onDoubleTap,
    this.onLongPress,
    required this.minHeight,
    required this.nodeIndent,
    required this.additionalLeafIndent,
    required this.expandIcon,
    required this.collapseIcon,
    required this.keyColor,
    required this.numColor,
    required this.stringColor,
    required this.boolColor,
    required this.arrayColor,
    required this.objectColor,
    required this.noneColor,
    required this.hiddenColor,
    required this.hiddenTextColor,
    this.nodeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    String? key = node.describeKey;

    double depthPadding = nodeIndent * node.depth;
    if (!node.isRoot && !node.hasChildren) {
      depthPadding += additionalLeafIndent;
    }

    bool isHidden = node.key is String &&
        hiddenKeys.any((e) => e == node.key?.toLowerCase());

    Widget child = Text.rich(
      TextSpan(
        children: [
          if (key != null)
            TextSpan(
              text: key,
              style: TextStyle(
                color: keyColor,
              ),
            ),
          !isHidden ? buildValueWidget() : buildHiddenValueWidget(),
        ],
      ),
    );

    child = nodeBuilder?.call(context, index, node, child) ?? child;

    return Padding(
      padding: EdgeInsets.only(left: depthPadding),
      child: InkWell(
        onTap: node.hasChildren
            ? () {
                node.expanded = !node.expanded;
                onToggle.call(node.expanded);
              }
            : null,
        onDoubleTap: !isHidden ? onDoubleTap : null,
        onLongPress: !isHidden ? onLongPress : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: Row(
              children: [
                if (node.hasChildren) node.expanded ? expandIcon : collapseIcon,
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InlineSpan buildValueWidget() {
    return TextSpan(
      text: node.describeValue,
      style: TextStyle(
        color: _getColor(node.type),
      ),
    );
  }

  InlineSpan buildHiddenValueWidget() {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        decoration: BoxDecoration(
          color: hiddenColor,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 6,
        ),
        child: Text(
          "Hidden",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: hiddenTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getColor(ValueType type) {
    switch (type) {
      case ValueType.num:
        return numColor;
      case ValueType.string:
        return stringColor;
      case ValueType.bool:
        return boolColor;
      case ValueType.array:
        return arrayColor;
      case ValueType.object:
        return objectColor;
      case ValueType.none:
        return noneColor;
    }
  }
}
