//screen/admin/admin_home.dart
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'admin_product_screen.dart';
import 'admin_orders.dart';

const Color _green = Color(0xFF1FD58B);

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;
  int _productTabIndex = 0;

  ///  Change Bottom Tab
  void changeTab(int index) {
    setState(() {
      _index = index;
    });
  }

  ///  Open Product Tab from Dashboard
  void openProductTab(int tabIndex) {
    setState(() {
      _index = 1;
      _productTabIndex = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      ///  BODY (NO APPBAR CONFLICT)
      body: IndexedStack(
        index: _index,
        children: [
          AdminDashboard(
            onNavigate: changeTab,
            onOpenProductTab: openProductTab,
          ),
          AdminProductScreen(initialTabIndex: _productTabIndex),
          const AdminOrders(),
        ],
      ),

      ///  FLOATING BUTTON (ONLY PRODUCT SCREEN)
      floatingActionButton: _index == 1
          ? FloatingActionButton(
              backgroundColor: _green,
              onPressed: () {
                // You can connect this to Add Product dialog later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Add Product Clicked")),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      ///  BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: changeTab,
        selectedItemColor: _green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: "Products",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.receipt_long_outlined),
          //   activeIcon: Icon(Icons.receipt),
          //   label: "Orders",
          // ),
        ],
      ),
    );
  }
}