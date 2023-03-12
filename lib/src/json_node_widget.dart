import 'package:flutter/material.dart';

import 'model/json_node.dart';
import 'model/value_type.dart';

class JsonNodeWidget extends StatelessWidget {
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

  const JsonNodeWidget({
    super.key,
    required this.node,
    required this.hiddenKeys,
    required this.onToggle,
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
  });

  @override
  Widget build(BuildContext context) {
    String? key = _describeKey(node);

    double depthPadding = nodeIndent * node.depth;
    if (!node.isExpandable && node.key != null) {
      depthPadding += additionalLeafIndent;
    }

    bool allowExpand =
        node.isExpandable && node.value is List && node.value.length > 0;

    bool isHidden = node.key is String &&
        hiddenKeys.any((e) => e == node.key?.toLowerCase());

    return Padding(
      padding: EdgeInsets.only(left: depthPadding),
      child: InkWell(
        onTap: allowExpand
            ? () {
                node.expanded = !node.expanded;
                onToggle.call(node.expanded);
              }
            : null,
        onLongPress: !isHidden ? onLongPress : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: Row(
              children: [
                if (allowExpand) node.expanded ? expandIcon : collapseIcon,
                Expanded(
                  child: isHidden
                      ? Row(
                          children: [
                            if (key != null)
                              Text(
                                key,
                                style: TextStyle(
                                  color: keyColor,
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                color: hiddenColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 6,
                              ),
                              child: const Text(
                                "Hidden",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text.rich(
                          TextSpan(
                            children: [
                              if (key != null)
                                TextSpan(
                                  text: key,
                                  style: TextStyle(
                                    color: keyColor,
                                  ),
                                ),
                              TextSpan(
                                text: _describeValue(node),
                                style: TextStyle(
                                  color: _getColor(node.type),
                                ),
                              ),
                            ],
                          ),
                          // maxLines: 1,
                          // overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _describeKey(JsonNode node) {
    return node.key != null ? "${node.key}: " : null;
  }

  static String _describeValue(JsonNode node) {
    if (node.value is! List) {
      String value =
          node.value is String ? '"${node.value}"' : node.value.toString();
      return value;
    } else {
      List children = node.value;
      if (node.type == ValueType.array) {
        if (children.isEmpty) {
          return "Array[0]";
        } else {
          dynamic child = children[0];
          String type = child is JsonNode
              ? child.type == ValueType.object
                  ? "Object"
                  : child.type.name
              : child.runtimeType.toString();
          return "Array<$type>[${children.length}]";
        }
      } else if (node.type == ValueType.object) {
        return "Object";
      } else {
        return node.type.name;
      }
    }
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
