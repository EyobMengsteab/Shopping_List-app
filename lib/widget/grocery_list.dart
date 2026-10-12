import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:shopping_list/models/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
      'shopping-list-9e106-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Please try again later.');
    }

    if (response.body == 'null') {
      return const [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
            orElse: () => categories.entries.first,
          )
          .value;

      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    return loadedItems;
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _loadedItems = _loadItems();
    });
  }

  Future<void> _removeItem(GroceryItem item) async {
    final url = Uri.https(
      'shopping-list-9e106-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item. Please try again.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _loadedItems = _loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder<List<GroceryItem>>(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final items = snapshot.data ?? const <GroceryItem>[];

          if (items.isEmpty) {
            return const Center(child: Text('No items added yet.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              final item = items[index];
              return Dismissible(
                key: ValueKey(item.id),
                onDismissed: (direction) {
                  _removeItem(item);
                },
                child: ListTile(
                  title: Text(item.name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: item.category.color,
                  ),
                  trailing: Text(item.quantity.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
