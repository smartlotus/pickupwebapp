import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'ai_hub_screen.dart';
import '../providers/capsule_provider.dart';
import '../widgets/new_user_tutorial.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AiHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CapsuleProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final showTutorial = !provider.isLoading && !provider.tutorialCompleted;
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          if (showTutorial)
            Positioned.fill(
              child: NewUserTutorial(
                onFinish: () => context.read<CapsuleProvider>().completeTutorial(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF161616),
          selectedItemColor: accent,
          unselectedItemColor: Colors.white54,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.book),
              label: provider.t('nav_pickup'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.psychology),
              label: provider.t('nav_ai_hub'),
            ),
          ],
        ),
      ),
    );
  }
}
