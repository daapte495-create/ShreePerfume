//screen/admin/admin_product_screen.dart
import 'package:flutter/material.dart';

import 'package:shree/core/app_state.dart';
import 'package:shree/models/category_model.dart';
import 'package:shree/models/product_model.dart';
import 'package:shree/models/user_model.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);
const Color _surface = Color(0xFFF7FAFD);
const List<String> _userRoles = <String>['Customer', 'Admin'];

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key, this.initialTabIndex = 0})
      : assert(initialTabIndex >= 0 && initialTabIndex < 4,
            'initialTabIndex must be between 0 and 3');

  final int initialTabIndex;

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTabIndex.clamp(0, 3);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void didUpdateWidget(covariant AdminProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != oldWidget.initialTabIndex &&
        widget.initialTabIndex != _tabController.index) {
      _tabController.index = widget.initialTabIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openProductForm(
    BuildContext context,
    AppState appState, {
    Product? product,
  }) async {
    final categories = appState.categories
        .map((category) => category.name)
        .toList();
    if (categories.isEmpty) {
      _showMessage(context, 'Add a category first before creating products');
      return;
    }

    final result = await showDialog<_ProductFormValue>(
      context: context,
      builder: (_) =>
          _ProductFormDialog(product: product, categories: categories),
    );

    if (result == null || !context.mounted) return;

    if (product == null) {
      print('➕ Adding product: ${result.name}');
      await appState.addProduct(
        name: result.name,
        price: result.price,
        category: result.category,
        image: result.image,
      );
      if (!context.mounted) return;
      _showMessage(context, '${result.name} added successfully');
      return;
    }

    await appState.updateProduct(
      product,
      name: result.name,
      price: result.price,
      category: result.category,
      image: result.image,
    );
    if (!context.mounted) return;
    _showMessage(context, '${result.name} updated successfully');
  }

  Future<void> _deleteProduct(
    BuildContext context,
    AppState appState,
    Product product,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Delete ${product.title} from the catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    await appState.deleteProduct(product);
    if (!context.mounted) return;
    _showMessage(context, '${product.title} deleted successfully');
  }

  Future<void> _openUserForm(
    BuildContext context,
    AppState appState, {
    AppUser? user,
  }) async {
    final result = await showDialog<_UserFormValue>(
      context: context,
      builder: (_) => _UserFormDialog(user: user),
    );

    if (result == null || !context.mounted) return;

    if (user == null) {
      appState.addUser(
        name: result.name,
        email: result.email,
        role: result.role,
      );
      if (!context.mounted) return;
      _showMessage(context, '${result.name} added successfully');
      return;
    }

    appState.updateUser(
      user,
      name: result.name,
      email: result.email,
      role: result.role,
    );
    if (!context.mounted) return;
    _showMessage(context, '${result.name} updated successfully');
  }

  Future<void> _deleteUser(
    BuildContext context,
    AppState appState,
    AppUser user,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Delete ${user.name} from your user list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    appState.deleteUser(user);
    if (!context.mounted) return;
    _showMessage(context, '${user.name} deleted successfully');
  }

  Future<void> _openCategoryForm(
    BuildContext context,
    AppState appState, {
    AppCategory? category,
  }) async {
    final result = await showDialog<_CategoryFormValue>(
      context: context,
      builder: (_) => _CategoryFormDialog(category: category),
    );

    if (result == null || !context.mounted) return;

    if (category == null) {
      await appState.addCategory(name: result.name, description: result.description);
      if (!context.mounted) return;
      _showMessage(context, '${result.name} added successfully');
      return;
    }

    await appState.updateCategory(
      category,
      name: result.name,
      description: result.description,
    );
    if (!context.mounted) return;
    _showMessage(context, '${result.name} updated successfully');
  }

  Future<void> _deleteCategory(
    BuildContext context,
    AppState appState,
    AppCategory category,
  ) async {
    final linkedProducts = appState.productCountForCategory(category.name);
    final fallbackCategory = appState.fallbackCategoryFor(category.name);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category'),
        content: Text(
          linkedProducts == 0
              ? 'Delete ${category.name} from your category list?'
              : 'Delete ${category.name}? $linkedProducts linked product${linkedProducts == 1 ? '' : 's'} will move to $fallbackCategory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    await appState.deleteCategory(category);
    if (!context.mounted) return;
    final message = linkedProducts == 0
        ? '${category.name} deleted successfully'
        : '${category.name} deleted and linked products moved to $fallbackCategory';
    _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Admin Panel',
              style: TextStyle(
                color: _dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(68),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE3EBF4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: _muted,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: const [
                        Tab(text: 'Products'),
                        Tab(text: 'Users'),
                        Tab(text: 'Categories'),
                        Tab(text: 'Orders'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ProductAdminTab(
                    appState: appState,
                    onAdd: () => _openProductForm(context, appState),
                    onEdit: (product) =>
                        _openProductForm(context, appState, product: product),
                    onDelete: (product) =>
                        _deleteProduct(context, appState, product),
                  ),
                  _UserAdminTab(
                    appState: appState,
                    onAdd: () => _openUserForm(context, appState),
                    onEdit: (user) =>
                        _openUserForm(context, appState, user: user),
                    onDelete: (user) => _deleteUser(context, appState, user),
                  ),
                  _CategoryAdminTab(
                    appState: appState,
                    onAdd: () => _openCategoryForm(context, appState),
                    onEdit: (category) => _openCategoryForm(
                      context,
                      appState,
                      category: category,
                    ),
                    onDelete: (category) =>
                        _deleteCategory(context, appState, category),
                  ),
                  _OrdersAdminTab(appState: appState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductAdminTab extends StatelessWidget {
  const _ProductAdminTab({
    required this.appState,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AppState appState;
  final VoidCallback onAdd;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  @override
  Widget build(BuildContext context) {
    final products = appState.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminSummaryCard(
          title: 'Manage products',
          subtitle: '${products.length} products in your catalog',
          buttonLabel: 'Add New Product',
          buttonIcon: Icons.add_circle_outline_rounded,
          onPressed: onAdd,
        ),
        const SizedBox(height: 20),
        const Text(
          'Catalog',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: products.isEmpty
              ? const _EmptyAdminState(
                  icon: Icons.inventory_2_outlined,
                  message:
                      'No products yet. Add your first product to start managing the catalog.',
                )
              : ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _AdminProductCard(
                      product: product,
                      onEdit: () => onEdit(product),
                      onDelete: () => onDelete(product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _UserAdminTab extends StatelessWidget {
  const _UserAdminTab({
    required this.appState,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AppState appState;
  final VoidCallback onAdd;
  final ValueChanged<AppUser> onEdit;
  final ValueChanged<AppUser> onDelete;

  @override
  Widget build(BuildContext context) {
    final users = appState.users;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminSummaryCard(
          title: 'Manage users',
          subtitle: '${users.length} accounts available for review',
          buttonLabel: 'Add New User',
          buttonIcon: Icons.person_add_alt_1_rounded,
          onPressed: onAdd,
        ),
        const SizedBox(height: 20),
        const Text(
          'User accounts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: users.isEmpty
              ? const _EmptyAdminState(
                  icon: Icons.people_alt_outlined,
                  message:
                      'No users yet. Add your first account to start managing customers.',
                )
              : ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _AdminUserCard(
                      user: user,
                      onEdit: () => onEdit(user),
                      onDelete: () => onDelete(user),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryAdminTab extends StatelessWidget {
  const _CategoryAdminTab({
    required this.appState,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AppState appState;
  final VoidCallback onAdd;
  final ValueChanged<AppCategory> onEdit;
  final ValueChanged<AppCategory> onDelete;

  @override
  Widget build(BuildContext context) {
    final categories = appState.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminSummaryCard(
          title: 'Manage categories',
          subtitle:
              '${categories.length} category groups available for products',
          buttonLabel: 'Add New Category',
          buttonIcon: Icons.category_outlined,
          onPressed: onAdd,
        ),
        const SizedBox(height: 20),
        const Text(
          'Category groups',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _dark,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: categories.isEmpty
              ? const _EmptyAdminState(
                  icon: Icons.category_outlined,
                  message:
                      'No categories yet. Add your first category to start organizing products.',
                )
              : ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _AdminCategoryCard(
                      category: category,
                      productCount: appState.productCountForCategory(
                        category.name,
                      ),
                      onEdit: () => onEdit(category),
                      onDelete: () => onDelete(category),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AdminSummaryCard extends StatelessWidget {
  const _AdminSummaryCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: _muted)),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(buttonIcon),
              label: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminProductCard extends StatelessWidget {
  const _AdminProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B1B34),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFFF8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: product.image.isEmpty
                  ? const Icon(
                      Icons.local_mall_outlined,
                      color: _green,
                      size: 28,
                    )
                  : product.image.contains('://')
                      ? Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const ColoredBox(
                            color: Color(0xFFEFFFF8),
                            child: Icon(
                              Icons.local_mall_outlined,
                              color: _green,
                              size: 28,
                            ),
                          ),
                        )
                      : Image.asset(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const ColoredBox(
                            color: Color(0xFFEFFFF8),
                            child: Icon(
                              Icons.local_mall_outlined,
                              color: _green,
                              size: 28,
                            ),
                          ),
                        ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.category,
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
                const SizedBox(height: 8),
                Text(
                  product.formattedPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit product',
                icon: const Icon(Icons.edit_outlined, color: _dark),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete product',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  const _AdminUserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final AppUser user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'Admin';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B1B34),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAdmin
                  ? const Color(0xFFEAFBF5)
                  : const Color(0xFFF3F7FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              user.initials,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isAdmin ? _green : const Color(0xFF5471A8),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? const Color(0xFFEAFBF5)
                            : const Color(0xFFF1F5FB),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isAdmin ? _green : const Color(0xFF5E708F),
                        ),
                      ),
                    ),
                    Text(
                      'Since ${user.memberSinceLabel}',
                      style: const TextStyle(fontSize: 12.5, color: _muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit user',
                icon: const Icon(Icons.edit_outlined, color: _dark),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete user',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminCategoryCard extends StatelessWidget {
  const _AdminCategoryCard({
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  final AppCategory category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B1B34),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFFF8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.category_outlined, color: _green, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _muted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFBF5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '$productCount product${productCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit category',
                icon: const Icon(Icons.edit_outlined, color: _dark),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete category',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EBF4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42, color: _muted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _muted),
          ),
        ],
      ),
    );
  }
}

// ---------------- PRODUCT FORM ----------------
class _ProductFormValue {
  final String name;
  final double price;
  final String category;
  final String brand;
  final String description;
  final String scentFamily;
  final String image;

  const _ProductFormValue({
    required this.name,
    required this.price,
    required this.category,
    required this.brand,
    required this.description,
    required this.scentFamily,
    required this.image,
  });
}

class _ProductFormDialog extends StatefulWidget {
  final Product? product;
  final List<String> categories;
  const _ProductFormDialog({this.product, required this.categories});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scentController = TextEditingController();
  final _imageController = TextEditingController();
  String? _selectedCategory;
  String _previewImage = '';

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.title;
      _priceController.text = widget.product!.price.toString();
      _brandController.text = widget.product!.brand;
      _descriptionController.text = widget.product!.description;
      _scentController.text = widget.product!.scentFamily;
      String imagePath = widget.product!.image;
      if (imagePath.startsWith('assets/')) {
        imagePath = imagePath.replaceFirst('assets/', '');
      }
      _imageController.text = imagePath;
      _selectedCategory = widget.product!.category;
    }
    _previewImage = _normalizeImagePath(_imageController.text.trim());
  }

  String _normalizeImagePath(String input) {
    if (input.isEmpty) return '';
    final trimmed = input.trim();
    if (trimmed.contains('://')) return trimmed;
    return trimmed.startsWith('assets/') ? trimmed : 'assets/$trimmed';
  }

  void _onImageChanged(String value) {
    setState(() {
      _previewImage = _normalizeImagePath(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Brand')),
            TextField(controller: _scentController, decoration: const InputDecoration(labelText: 'Scent Family')),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(
              controller: _imageController,
              onChanged: _onImageChanged,
              decoration: const InputDecoration(
                labelText: 'Image Path',
                hintText: 'e.g., perfume1.webp or assets/perfume1.webp',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 160,
              child: _previewImage.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Image preview will appear here',
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _previewImage.contains('://')
                          ? Image.network(
                              _previewImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Invalid image URL',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              _previewImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Asset not found',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                );
                              },
                            ),
                    ),
          ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final imageInput = _imageController.text.trim();
            String finalImage = imageInput;
            if (imageInput.isNotEmpty && !imageInput.startsWith('assets/') && !imageInput.contains('://')) {
              finalImage = 'assets/$imageInput';
            }
            Navigator.pop(
              context,
              _ProductFormValue(
                name: _nameController.text.trim(),
                price: double.tryParse(_priceController.text.trim()) ?? 0,
                category: _selectedCategory ?? '',
                brand: _brandController.text.trim(),
                description: _descriptionController.text.trim(),
                scentFamily: _scentController.text.trim(),
                image: finalImage,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
//======================================================
// class _ProductFormDialog extends StatefulWidget {
//   const _ProductFormDialog({this.product, required this.categories});

//   final Product? product;
//   final List<String> categories;

//   @override
//   State<_ProductFormDialog> createState() => _ProductFormDialogState();
// }

// class _ProductFormDialogState extends State<_ProductFormDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController _nameController;
//   late final TextEditingController _priceController;
//   late String _selectedCategory;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.product?.title ?? '');
//     _priceController = TextEditingController(
//       text: widget.product?.price.toStringAsFixed(2) ?? '',
//     );
//     _selectedCategory = widget.product?.category ?? widget.categories.first;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     final isValid = _formKey.currentState?.validate() ?? false;
//     if (!isValid) return;

//     Navigator.pop(
//       context,
//       _ProductFormValue(
//         name: _nameController.text.trim(),
//         price: double.parse(_priceController.text.trim()),
//         category: _selectedCategory,
//       ),
//     );
//   }

//   String? _validateName(String? value) {
//     final name = value?.trim() ?? '';
//     if (name.isEmpty) return 'Enter product name';
//     return null;
//   }

//   String? _validatePrice(String? value) {
//     final price = double.tryParse(value?.trim() ?? '');
//     if (price == null) return 'Enter a valid price';
//     if (price <= 0) return 'Price must be greater than 0';
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.product != null;

//     return AlertDialog(
//       title: Text(isEditing ? 'Update product' : 'Add product'),
//       content: SizedBox(
//         width: 360,
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 textInputAction: TextInputAction.next,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   hintText: 'Rose Musk',
//                 ),
//                 validator: _validateName,
//               ),
//               const SizedBox(height: 14),
//               TextFormField(
//                 controller: _priceController,
//                 keyboardType: const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 textInputAction: TextInputAction.next,
//                 decoration: const InputDecoration(
//                   labelText: 'Price',
//                   hintText: '120',
//                 ),
//                 validator: _validatePrice,
//               ),
//               const SizedBox(height: 14),
//               DropdownButtonFormField<String>(
//                 initialValue: _selectedCategory,
//                 decoration: const InputDecoration(labelText: 'Category'),
//                 items: widget.categories
//                     .map(
//                       (category) => DropdownMenuItem<String>(
//                         value: category,
//                         child: Text(category),
//                       ),
//                     )
//                     .toList(),
//                 onChanged: (value) {
//                   if (value == null) return;
//                   setState(() => _selectedCategory = value);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _submit,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _green,
//             foregroundColor: Colors.white,
//           ),
//           child: Text(isEditing ? 'Update' : 'Add'),
//         ),
//       ],
//     );
//   }
// }
//======================================================
class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({this.user});

  final AppUser? user;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _selectedRole = widget.user?.role ?? _userRoles.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    Navigator.pop(
      context,
      _UserFormValue(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
      ),
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter full name';
    if (name.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter email address';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (AppState.instance.emailExists(email, exceptId: widget.user?.id)) {
      return 'This email is already in use';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return AlertDialog(
      title: Text(isEditing ? 'Update user' : 'Add user'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Ava Wilson',
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'ava@example.com',
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _userRoles
                    .map(
                      (role) => DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedRole = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});

  final AppCategory? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    Navigator.pop(
      context,
      _CategoryFormValue(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter category name';
    if (name.length < 3) return 'Category name must be at least 3 characters';
    if (AppState.instance.categoryExists(name, exceptId: widget.category?.id)) {
      return 'This category already exists';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.isEmpty) return 'Enter category description';
    if (description.length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing ? 'Update category' : 'Add category'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Seasonal',
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Fresh category copy for your admin catalog.',
                ),
                validator: _validateDescription,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}

// class _ProductFormValue {
//   const _ProductFormValue({
//     required this.name,
//     required this.price,
//     required this.category,
//   });

//   final String name;
//   final double price;
//   final String category;
// }

class _UserFormValue {
  const _UserFormValue({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;
}

class _OrdersAdminTab extends StatelessWidget {
  const _OrdersAdminTab({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Orders (${appState.orders.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),
        ),
        Expanded(
          child: appState.orders.isEmpty
              ? const Center(
                  child: Text('No orders yet'),
                )
              : ListView.builder(
                  itemCount: appState.orders.length,
                  itemBuilder: (context, index) {
                    final order = appState.orders[index];
                    return Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE6EDF5)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x080B1B34),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order: ${order.id}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: _dark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Customer: ${order.shippingName}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _muted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total: ${order.formattedTotalAmount}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (status) async {
                                  if (status == 'Cancelled') {
                                    final shouldCancel = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Cancel order'),
                                        content: Text('Cancel order ${order.id}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('No'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Cancel Order'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (shouldCancel != true) return;
                                  }
                                  appState.updateOrderStatus(order.id, status);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'Pending',
                                    child: Text('Pending'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Processing',
                                    child: Text('Processing'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Shipped',
                                    child: Text('Shipped'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Delivered',
                                    child: Text('Delivered'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Cancelled',
                                    child: Text('Cancelled'),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: order.status == 'Delivered'
                                        ? Colors.green.shade100
                                        : order.status == 'Shipped'
                                            ? Colors.blue.shade100
                                            : order.status == 'Cancelled'
                                                ? Colors.red.shade100
                                                : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: order.status == 'Delivered'
                                          ? Colors.green.shade700
                                          : order.status == 'Shipped'
                                              ? Colors.blue.shade700
                                              : order.status == 'Cancelled'
                                                  ? Colors.red.shade700
                                                  : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Items (${order.itemCount}):',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...order.items.map(
                            (item) => Text(
                              '• ${item.title} x${item.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryFormValue {
  const _CategoryFormValue({required this.name, required this.description});

  final String name;
  final String description;
}
