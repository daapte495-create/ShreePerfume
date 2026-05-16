// import 'package:flutter/material.dart';
// import 'package:shree/core/app_state.dart';

// const Color _green = Color(0xFF1FD58B);
// const Color _dark = Color(0xFF1D2740);
// const Color _muted = Color(0xFF8B9AB0);
// const Color _surface = Color(0xFFF7FAFD);

// class AdminDashboard extends StatelessWidget {
//   final Function(int) onNavigate;
//   final Function(int) onOpenProductTab;

//   const AdminDashboard({
//     super.key,
//     required this.onNavigate,
//     required this.onOpenProductTab,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final appState = AppState.instance;

//     return SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ///  HEADER WITH LOGOUT
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF1FD58B), Color(0xFF17B978)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Hello Admin 👋",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 6),
//                       Text(
//                         "Manage your perfume store easily",
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ],
//                   ),

//                   ///  LOGOUT BUTTON
//                   IconButton(
//                     onPressed: () {
//                       _showLogoutDialog(context);
//                     },
//                     icon: const Icon(Icons.logout, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             ///  DASHBOARD CARDS
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               children: [
//                 _card("Products", appState.products.length, Icons.shopping_bag),
//                 _card("Users", appState.users.length, Icons.people),
//                 _card("Categories", appState.categories.length, Icons.category),
//                 _card("Orders", 0, Icons.receipt),
//               ],
//             ),

//             const SizedBox(height: 25),

//             ///  QUICK ACTIONS
//             const Text(
//               "Quick Actions",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: _dark,
//               ),
//             ),

//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 Expanded(
//                   child: _actionButton(
//                     "Add Product",
//                     Icons.add,
//                     () => onOpenProductTab(0),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: _actionButton(
//                     "Add Category",
//                     Icons.category,
//                     () => onOpenProductTab(2),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             Row(
//               children: [
//                 Expanded(
//                   child: _actionButton(
//                     "Add User",
//                     Icons.person_add,
//                     () => onOpenProductTab(1),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: _actionButton(
//                     "View Orders",
//                     Icons.receipt,
//                     () => onNavigate(2),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 25),

//             ///  ANALYTICS
//             const Text(
//               "Analytics",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//                 color: _dark,
//               ),
//             ),

//             const SizedBox(height: 12),

//             Container(
//               height: 150,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: _surface,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: const Color(0xFFE3EBF4)),
//               ),
//               child: const Center(
//                 child: Text(
//                   "Sales Chart Coming Soon 📊",
//                   style: TextStyle(color: _muted),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   ///  CARD
//   Widget _card(String title, int count, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: _green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: _green),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "$count",
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: _dark,
//             ),
//           ),
//           Text(title, style: const TextStyle(color: _muted)),
//         ],
//       ),
//     );
//   }

//   ///  BUTTON
//   Widget _actionButton(String text, IconData icon, VoidCallback onTap) {
//     return ElevatedButton.icon(
//       onPressed: onTap,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _green,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 14),
//       ),
//       icon: Icon(icon),
//       label: Text(text),
//     );
//   }

//   /// LOGOUT DIALOG
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to logout?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);

//               ///  CLEAR STATE (customize if needed)
//               // AppState.instance.logout();

//               ///  REDIRECT
//               Navigator.pushReplacementNamed(context, "/login");
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:shree/core/app_state.dart';
import 'package:shree/screens/auth/login_screen.dart';

const Color _green = Color(0xFF1FD58B);
const Color _dark = Color(0xFF1D2740);
const Color _muted = Color(0xFF8B9AB0);
const Color _surface = Color(0xFFF7FAFD);

class AdminDashboard extends StatelessWidget {
  final Function(int) onNavigate;
  final Function(int) onOpenProductTab;

  const AdminDashboard({
    super.key,
    required this.onNavigate,
    required this.onOpenProductTab,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      backgroundColor: _surface,

      /// TOP APPBAR WITH LOGOUT
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///  HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1FD58B), Color(0xFF17B978)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello Admin 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Manage your perfume store easily",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ///  DASHBOARD CARDS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _card("Products", appState.products.length, Icons.shopping_bag),
                  _card("Users", appState.users.length, Icons.people),
                  _card("Categories", appState.categories.length, Icons.category),
                  _card("Orders", appState.orders.length, Icons.receipt),
                ],
              ),

              const SizedBox(height: 25),

              ///  QUICK ACTIONS
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      "Add Product",
                      Icons.add,
                      () => onOpenProductTab(0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      "Add Category",
                      Icons.category,
                      () => onOpenProductTab(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      "Add User",
                      Icons.person_add,
                      () => onOpenProductTab(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      "View Orders",
                      Icons.receipt,
                      () => onOpenProductTab(3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// ANALYTICS
              const Text(
                "Analytics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE3EBF4)),
                ),
                child: const Center(
                  child: Text(
                    "Sales Chart Coming Soon 📊",
                    style: TextStyle(color: _muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///  CARD
  Widget _card(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _green),
          ),
          const SizedBox(height: 10),
          Text(
            "$count",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _dark,
            ),
          ),
          Text(title, style: const TextStyle(color: _muted)),
        ],
      ),
    );
  }

  ///  BUTTON
  Widget _actionButton(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: Icon(icon),
      label: Text(text),
    );
  }

  ///  LOGOUT DIALOG
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => LoginScreen(),
  ),
);            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}