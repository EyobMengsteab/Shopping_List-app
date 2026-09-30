import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.diary]!),
  GroceryItem(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: 'Beaf Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
  GroceryItem(
      id: 'd',
      name: 'Carrot',
      quantity: 3,
      category: categories[Categories.vegetables]!),
  GroceryItem(
      id: 'e',
      name: 'Bread',
      quantity: 1,
      category: categories[Categories.carbs]!),
];