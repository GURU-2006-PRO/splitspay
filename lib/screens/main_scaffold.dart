import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/constants.dart';
import 'groups_screen.dart';
import 'wallet_screen.dart';
import 'payment_screen.dart';
import 'chatbot_screen.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final List<Widget> screens = [
      const GroupsScreen(),
      const WalletScreen(),
      const PaymentScreen(),
      const ChatbotScreen(),
    ];

    final List<String> titles = [
      'Groups',
      'Wallet',
      'Payment',
      'TripBot',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[navProvider.currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(user?.name ?? 'User'),
              accountEmail: Text(user?.phoneNumber ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 24, color: AppColors.primary),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('My Groups'),
              onTap: () {
                navProvider.setIndex(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Wallet'),
              onTap: () {
                navProvider.setIndex(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Make Payment'),
              onTap: () {
                navProvider.setIndex(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('TripBot Assistant'),
              onTap: () {
                navProvider.setIndex(3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                authProvider.logout();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navProvider.currentIndex,
        onDestinationSelected: (index) => navProvider.setIndex(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.payment_outlined),
            selectedIcon: Icon(Icons.payment),
            label: 'Payment',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'TripBot',
          ),
        ],
      ),
    );
  }
}
