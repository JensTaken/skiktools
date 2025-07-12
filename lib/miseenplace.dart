import 'package:flutter/material.dart';
import 'package:skiktools/constants.dart';

class MiseEnPlacePage extends StatefulWidget {
  const MiseEnPlacePage({super.key});

  @override
  State<MiseEnPlacePage> createState() => _MiseEnPlacePageState();
}

class _MiseEnPlacePageState extends State<MiseEnPlacePage> {
  List<String> selectedProducts = [];
  Map<String, bool> completedProducts = {};
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // No need to sort here as we'll sort in the getter
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addProduct(String product) {
    setState(() {
      if (!selectedProducts.contains(product)) {
        selectedProducts.add(product);
        completedProducts[product] = false;
      }
    });
  }

  void _removeProduct(String product) {
    setState(() {
      selectedProducts.remove(product);
      completedProducts.remove(product);
    });
  }

  void _toggleComplete(String product) {
    setState(() {
      completedProducts[product] = !completedProducts[product]!;
    });
  }

  void _resetList() {
    setState(() {
      completedProducts.updateAll((key, value) => false);
    });
  }

  void _clearList() {
    setState(() {
      selectedProducts.clear();
      completedProducts.clear();
    });
  }

  List<String> get allProducts {
    return basisProducten.map((product) => product['naam'] as String).toList()..sort();
  }

  List<String> get filteredProducts {
    if (searchQuery.isEmpty) {
      return allProducts;
    }
    return allProducts.where((product) =>
        product.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Mise en Place',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              // Reset and Clear buttons
              ElevatedButton.icon(
                onPressed: selectedProducts.isEmpty ? null : _resetList,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: selectedProducts.isEmpty ? null : _clearList,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Leeg maken', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Main content
          Expanded(
            child: Row(
              children: [
                // Left side - Product list
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Zoek product...',
                              prefixIcon: Icon(Icons.search, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        
                        // Product list
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              final isSelected = selectedProducts.contains(product);
                              
                              return ListTile(
                                dense: true,
                                title: Text(
                                  product,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? Colors.grey[600] : Colors.black,
                                  ),
                                ),
                                trailing: isSelected 
                                  ? const Icon(Icons.check, color: Colors.green, size: 18)
                                  : null,
                                onTap: () => _addProduct(product),
                                tileColor: isSelected ? Colors.grey[100] : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Right side - Checklist
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Checklist',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (selectedProducts.isNotEmpty) ...[
                                Text(
                                  '${completedProducts.values.where((completed) => completed).length}/${selectedProducts.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        
                        // Checklist items
                        Expanded(
                          child: selectedProducts.isEmpty
                            ? const Center(
                                child: Text(
                                  'Selecteer producten om een checklist te maken',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: selectedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = selectedProducts[index];
                                  final isCompleted = completedProducts[product] ?? false;
                                  
                                  return ListTile(
                                    dense: true,
                                    leading: Checkbox(
                                      value: isCompleted,
                                      onChanged: (value) => _toggleComplete(product),
                                      activeColor: Colors.green,
                                    ),
                                    title: Text(
                                      product,
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: isCompleted 
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                        color: isCompleted 
                                          ? Colors.grey[600]
                                          : Colors.black,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => _removeProduct(product),
                                      color: Colors.red,
                                    ),
                                    onTap: () => _toggleComplete(product),
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
