import 'package:flutter/material.dart';

import 'package:shree/core/app_state.dart';
import 'package:shree/models/product_model.dart';
import 'package:shree/screens/admin/admin_product_screen.dart';
import 'package:shree/screens/product/product_detail_screen.dart';
import 'package:shree/screens/widgets/wishlist_action_button.dart';
import 'package:shree/screens/wishlist/wishlist_screen.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  void _openWishlist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WishlistScreen()),
    );
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return const AdminProductScreen();
    }

    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final bestSellers = appState.products.take(4).toList(growable: false);
        final featuredProduct = bestSellers.isEmpty ? null : bestSellers.first;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            // leading: IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.bungalow, color: Color.fromARGB(255, 2, 70, 241)),
            // ),
            centerTitle: false,
            title: const Text(
              'Shree Perfume',
              style: TextStyle(
                color: _dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              WishlistActionButton(onTap: () => _openWishlist(context)),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HomeSearchBar(),
                const SizedBox(height: 20),
                _HeroBanner(
                  product: featuredProduct,
                  onTap: featuredProduct == null
                      ? null
                      : () => _openProduct(context, featuredProduct),
                ),
                const SizedBox(height: 28),
                const _SectionHeader(),
                const SizedBox(height: 14),
                if (appState.products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Loading products...',
                        style: TextStyle(color: _muted, fontSize: 14),
                      ),
                    ),
                  )
                else
                  _HomeGrid(
                    products: bestSellers,
                    onProductTap: (product) => _openProduct(context, product),
                    onWishlistTap: (product) {
                      final wasWishlisted = appState.isInWishlist(product);
                      appState.toggleWishlist(product);
                      _showMessage(
                        context,
                        wasWishlisted
                            ? '${product.title} removed from wishlist'
                            : '${product.title} added to wishlist',
                      );
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

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for luxury scents...',
        hintStyle: const TextStyle(color: Color(0xFFA1AEC1)),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF90A2BD)),
        filled: true,
        fillColor: const Color(0xFFF4F7FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E9F3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _green),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.product, required this.onTap});

  final Product? product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final bannerMinHeight = compact ? 212.0 : 190.0;
        final titleSize = compact ? 24.0 : 29.0;
        final bodySize = compact ? 13.0 : 14.0;
        final contentGap = compact ? 12.0 : 16.0;
        final imageWidth = compact ? 96.0 : 106.0;
        final imageHeight = compact ? 160.0 : 150.0;
        final featured = product;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: bannerMinHeight),
          padding: EdgeInsets.all(compact ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A233B), Color(0xFF6E4A1E), Color(0xFF281A13)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0B1B34),
                blurRadius: 22,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'BEST SELLERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: contentGap),
                    Text(
                      featured?.title ?? 'Luxury Fragrance Collection',
                      maxLines: compact ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      featured == null
                          ? 'Discover signature perfume bottles and timeless scents.'
                          : '${featured.category}  ${featured.scentFamily}  ${featured.formattedPrice}',
                      maxLines: compact ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFD7DDE8),
                        fontSize: bodySize,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: contentGap),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 16 : 18,
                          vertical: compact ? 10 : 12,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size(0, compact ? 38 : 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Product',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    SizedBox(
                      width: imageWidth,
                      height: imageHeight,
                      child: featured == null
                          ? const ColoredBox(color: Color(0x22FFFFFF))
                          : featured.image.isNotEmpty
                          ? Image.asset(
                              featured.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const ColoredBox(color: Color(0x22FFFFFF));
                              },
                            )
                          : const ColoredBox(color: Color(0x22FFFFFF)),
                    ),
                    if (featured != null)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.08),
                                featured.overlay,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Best Sellers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        // Text(
        //   'Tap to explore',
        //   style: TextStyle(
        //     color: _green,
        //     fontSize: 13,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
      ],
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid({
    required this.products,
    required this.onProductTap,
    required this.onWishlistTap,
    required this.isWishlisted,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onWishlistTap;
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
        childAspectRatio: 0.57,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          isWishlisted: isWishlisted(product),
          onTap: () => onProductTap(product),
          onWishlistTap: () => onWishlistTap(product),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistTap,
  });

  final Product product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
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
                        borderRadius: BorderRadius.circular(18),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 2),
            Text(
              '${product.category}  ${product.scentFamily}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: _muted),
            ),
            const SizedBox(height: 6),
            Text(
              product.formattedPrice,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
