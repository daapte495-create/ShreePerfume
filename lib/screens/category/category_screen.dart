import 'package:flutter/material.dart';
import 'package:shree/core/app_state.dart';
import 'package:shree/models/product_model.dart';
import 'package:shree/screens/product/product_detail_screen.dart';
import 'package:shree/screens/widgets/wishlist_action_button.dart';
import 'package:shree/screens/wishlist/wishlist_screen.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPrice = 'All';
  String _selectedFamily = 'All';

  List<String> get _familyOptions {
    final products = AppState.instance.products;
    return [
      'All',
      ...{for (final product in products) product.scentFamily},
    ];
  }

  List<Product> get _filteredProducts {
    final products = AppState.instance.products;
    final query = _searchController.text.trim().toLowerCase();
    return products.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.title.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.scentFamily.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      final matchesFamily =
          _selectedFamily == 'All' || product.scentFamily == _selectedFamily;
      final matchesPrice = switch (_selectedPrice) {
        'Under ₹5000' => product.price < 5000,
        '₹5000 - ₹7000' => product.price >= 5000 && product.price <= 7000,
        'Above ₹7000' => product.price > 7000,
        _ => true,
      };
      return matchesSearch && matchesFamily && matchesPrice;
    }).toList();
  }

  bool get _hasActiveSearch => _searchController.text.trim().isNotEmpty;
  bool get _hasActiveFilters =>
      _selectedPrice != 'All' || _selectedFamily != 'All';

  String get _resultTitle {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      return 'Results for "$query"';
    }
    if (_selectedFamily != 'All') {
      return 'Results for "$_selectedFamily"';
    }
    if (_selectedPrice != 'All') {
      return 'Results for "$_selectedPrice"';
    }
    return 'Discover Fragrances';
  }

  String get _resultSubtitle {
    if (_hasActiveSearch || _hasActiveFilters) {
      return 'Showing ${_filteredProducts.length} fragrances for your current search';
    }
    return 'Showing ${_filteredProducts.length} premium fragrances';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openWishlist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WishlistScreen()),
    );
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickPrice() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return _FilterPickerSheet(
          title: 'Price',
          options: const ['All', 'Under ₹5000', '₹5000 - ₹7000', 'Above ₹7000'],
          current: _selectedPrice,
        );
      },
    );

    if (selection != null) {
      setState(() => _selectedPrice = selection);
    }
  }

  Future<void> _pickFamily() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return _FilterPickerSheet(
          title: 'Scent Family',
          options: _familyOptions,
          current: _selectedFamily,
        );
      },
    );

    if (selection != null) {
      setState(() => _selectedFamily = selection);
    }
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return _AllFiltersSheet(
          selectedPrice: _selectedPrice,
          selectedFamily: _selectedFamily,
          familyOptions: _familyOptions,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPrice = result.price;
        _selectedFamily = result.family;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final filteredProducts = _filteredProducts;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Shree Perfume',
              style: TextStyle(
                color: _dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [WishlistActionButton(onTap: () => _openWishlist(context))],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategorySearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 22),
                Text(
                  _resultTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _resultSubtitle,
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
                const SizedBox(height: 16),
                _CategoryFilters(
                  selectedPrice: _selectedPrice,
                  selectedFamily: _selectedFamily,
                  onPriceTap: _pickPrice,
                  onFamilyTap: _pickFamily,
                  onFilterTap: _openFilters,
                ),
                const SizedBox(height: 20),
                if (filteredProducts.isEmpty)
                  const _EmptyResults()
                else
                  _CategoryGrid(
                    products: filteredProducts,
                    onProductTap: _openProduct,
                    onWishlistTap: (product) {
                      final wasInWishlist = appState.isInWishlist(product);
                      appState.toggleWishlist(product);
                      _showMessage(
                        wasInWishlist
                            ? '${product.title} removed from wishlist'
                            : '${product.title} added to wishlist',
                      );
                    },
                    onCartTap: (product) {
                      appState.addToCart(product);
                      _showMessage('${product.title} added to cart');
                    },
                    isWishlisted: appState.isInWishlist,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategorySearchBar extends StatelessWidget {
  const _CategorySearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search fragrances, brands, or categories...',
        hintStyle: const TextStyle(color: Color(0xFF89A5A3)),
        prefixIcon: const Icon(Icons.search_rounded, color: _green),
        filled: true,
        fillColor: const Color(0xFFEFFFF8),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _green),
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selectedPrice,
    required this.selectedFamily,
    required this.onPriceTap,
    required this.onFamilyTap,
    required this.onFilterTap,
  });

  final String selectedPrice;
  final String selectedFamily;
  final VoidCallback onPriceTap;
  final VoidCallback onFamilyTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: selectedPrice == 'All' ? 'Price' : selectedPrice,
            onTap: onPriceTap,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: selectedFamily == 'All' ? 'Scent Family' : selectedFamily,
            onTap: onFamilyTap,
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'Filters',
            filled: true,
            onTap: onFilterTap,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.filled = false,
    this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? _green : const Color(0xFFEFFFF8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: filled ? _green : const Color(0xFFC8F1DC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filled) ...[
              const Icon(Icons.tune_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : _green,
              ),
            ),
            if (!filled) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: _green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.products,
    required this.onProductTap,
    required this.onWishlistTap,
    required this.onCartTap,
    required this.isWishlisted,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onWishlistTap;
  final ValueChanged<Product> onCartTap;
  final bool Function(Product product) isWishlisted;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: 0.54,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _CategoryCard(
          product: product,
          onTap: () => onProductTap(product),
          onWishlistTap: () => onWishlistTap(product),
          onCartTap: () => onCartTap(product),
          isWishlisted: isWishlisted(product),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.product,
    required this.onTap,
    required this.onWishlistTap,
    required this.onCartTap,
    required this.isWishlisted,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onCartTap;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.image.isNotEmpty
                      ? Image.asset(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(color: Color(0xFFF4F7FB));
                          },
                        )
                      : const ColoredBox(color: Color(0xFFF4F7FB)),
                  ColoredBox(color: product.overlay),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: onWishlistTap,
                      borderRadius: BorderRadius.circular(16),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: const Color(0xFFD98693),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.brand,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: _green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${product.category} - ${product.scentFamily}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: _muted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.formattedPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onCartTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8F2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: _muted),
          SizedBox(height: 10),
          Text(
            'No fragrances match your search or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPickerSheet extends StatelessWidget {
  const _FilterPickerSheet({
    required this.title,
    required this.options,
    required this.current,
  });

  final String title;
  final List<String> options;
  final String current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 16),
          for (final option in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option),
              trailing: option == current
                  ? const Icon(Icons.check_rounded, color: _green)
                  : null,
              onTap: () => Navigator.pop(context, option),
            ),
        ],
      ),
    );
  }
}

class _AllFiltersSheet extends StatefulWidget {
  const _AllFiltersSheet({
    required this.selectedPrice,
    required this.selectedFamily,
    required this.familyOptions,
  });

  final String selectedPrice;
  final String selectedFamily;
  final List<String> familyOptions;

  @override
  State<_AllFiltersSheet> createState() => _AllFiltersSheetState();
}

class _AllFiltersSheetState extends State<_AllFiltersSheet> {
  late String selectedPrice = widget.selectedPrice;
  late String selectedFamily = widget.selectedFamily;

  @override
  Widget build(BuildContext context) {
    final priceOptions = ['All', 'Under ₹5000', '₹5000 - ₹7000', 'Above ₹7000'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Price',
            style: TextStyle(fontWeight: FontWeight.w700, color: _dark),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: priceOptions
                .map(
                  (option) => ChoiceChip(
                    label: Text(option),
                    selected: selectedPrice == option,
                    selectedColor: const Color(0xFFEFFFF8),
                    labelStyle: TextStyle(
                      color: selectedPrice == option ? _green : _dark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedPrice = option),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Scent Family',
            style: TextStyle(fontWeight: FontWeight.w700, color: _dark),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.familyOptions
                .map(
                  (option) => ChoiceChip(
                    label: Text(option),
                    selected: selectedFamily == option,
                    selectedColor: const Color(0xFFEFFFF8),
                    labelStyle: TextStyle(
                      color: selectedFamily == option ? _green : _dark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => selectedFamily = option),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedPrice = 'All';
                      selectedFamily = 'All';
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _FilterResult(
                        price: selectedPrice,
                        family: selectedFamily,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterResult {
  const _FilterResult({
    required this.price,
    required this.family,
  });

  final String price;
  final String family;
}
