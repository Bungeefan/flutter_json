import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json/flutter_json.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter JSON Demo",
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final JsonController _controller;
  final jsonObject = json.decode(jsonString);

  int? hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = JsonController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JSON Example")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _controller.expandAllNodes(),
                  icon: const Icon(Icons.unfold_more),
                  label: const Text("Expand all"),
                ),
                TextButton.icon(
                  onPressed: () => _controller.collapseAllNodes(),
                  icon: const Icon(Icons.unfold_less),
                  label: const Text("Collapse All"),
                ),
              ],
            ),
          ),
          Expanded(
            child: JsonWidget(
              controller: _controller,
              json: jsonObject,
              initialExpandDepth: 2,
              hiddenKeys: const ["hiddenField"],
              nodeBuilder: (context, index, node, child) {
                List<Widget> trailingWidgets = [];

                if (index == 0) {
                  trailingWidgets.add(
                    buildTrailingWidget(context, const Text("Root")),
                  );
                }

                if (node.type == ValueType.bool) {
                  trailingWidgets.add(
                    buildTrailingWidget(
                      context,
                      const Icon(Icons.toggle_off, size: 16),
                    ),
                  );
                }

                if ("city" == node.key) {
                  trailingWidgets.add(
                    buildTrailingWidget(
                      context,
                      const Icon(Icons.location_city, size: 16),
                    ),
                  );
                }

                if ("email" == node.key) {
                  trailingWidgets.add(
                    buildTrailingWidget(
                      context,
                      const Icon(Icons.alternate_email, size: 16),
                    ),
                  );
                }

                if ("price" == node.key) {
                  trailingWidgets.add(
                    buildTrailingWidget(
                      context,
                      const Icon(Icons.euro, size: 16),
                    ),
                  );
                }

                if (hoveredIndex == index) {
                  trailingWidgets.add(
                    buildTrailingWidget(
                      context,
                      const SizedBox.square(dimension: 5),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  );
                }

                return MouseRegion(
                  onHover: (event) {
                    if (hoveredIndex != index) {
                      setState(() => hoveredIndex = index);
                    }
                  },
                  onExit: (event) {
                    if (hoveredIndex != null) {
                      setState(() => hoveredIndex = null);
                    }
                  },
                  child: Row(children: [child, ...trailingWidgets]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTrailingWidget(
    BuildContext context,
    Widget child, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

const String jsonString = """
{
  "id": 1,
  "oldId": null,
  "active": true,
  "name": "John Doe",
  "email": "johndoe@example.com",
  "phone": "+1-202-555-0123",
  "address": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zip": "12345"
  },
  "aliases": [],
  "orders": [
    {
      "id": 1001,
      "items": [
        {
          "id": "A001",
          "name": "Widget A",
          "quantity": 2,
          "price": 9.99
        },
        {
          "id": "B002",
          "name": "Widget B",
          "quantity": 1,
          "price": 14.99
        }
      ],
      "total": 34.97,
      "status": "shipped"
    },
    {
      "id": 1002,
      "items": [
        {
          "id": "C003",
          "name": "Widget C",
          "quantity": 3,
          "price": 4.99,
          "hiddenField": "This field will be hidden"
        }
      ],
      "total": 14.97,
      "status": "pending"
    }
  ],
  "hiddenField": "This field will be hidden as well"
}
""";
