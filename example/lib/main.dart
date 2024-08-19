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

  @override
  void initState() {
    super.initState();
    _controller = JsonController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JSON Example"),
      ),
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
              json: json.decode(jsonString),
              initialExpandDepth: 2,
              hiddenKeys: const ["hiddenField"],
            ),
          ),
        ],
      ),
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
  "name": "John Doe",
  "email": "johndoe@example.com",
  "phone": "+1-202-555-0123",
  "address": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zip": "12345"
  },
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
