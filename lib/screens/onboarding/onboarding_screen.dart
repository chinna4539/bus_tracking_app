import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../models/onboarding_page_model.dart';
import '../../widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPageIndex = 0;

  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      title: 'Explore Vizag',
      subtitle:
          'Discover Visakhapatnam with APSRTC city buses. From Kailasagiri to the beach road, get around town easily.',
      asset: 'assets/images/vizag_city.jpg',
      caption: 'Visakhapatnam city from Kailasagiri',
    ),
    OnboardingPageModel(
      title: 'Find Your Bus',
      subtitle:
          'Search routes, stops, and bus numbers across Vizag. Plan your trip from Maddilapalem to anywhere in the city.',
      asset: 'assets/images/vizag_bus_stop.jpg',
      caption: 'GVMC Bus Stop, Yendada, Beach Road',
    ),
    OnboardingPageModel(
      title: 'Track Live',
      subtitle:
          'Follow your APSRTC bus in real time on the map. See live ETA, current stop, and nearby buses instantly.',
      asset: 'assets/images/vizag_bus_station.jpg',
      caption: 'Maddilapalem Bus Station',
    ),
  ];

  void _onNext() {
    if (_currentPageIndex < _pages.length - 1) {
      final nextPage = _currentPageIndex + 1;
      setState(() => _currentPageIndex = nextPage);
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'appLogo',
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 260,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (widget, animation) {
                                    final offsetAnimation =
                                        Tween<Offset>(
                                          begin: const Offset(0, 0.16),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOut,
                                          ),
                                        );
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: offsetAnimation,
                                        child: widget,
                                      ),
                                    );
                                  },
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  child: Image.asset(
                                    page.asset,
                                    key: ValueKey(page.asset),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 260,
                                  ),
                                ),
                              ),
                            ),
                           ),
                           const SizedBox(height: 16),
                           Text(
                             page.title,
                             style: TextStyle(
                               fontSize: 26,
                               fontWeight: FontWeight.w700,
                               color: Theme.of(context).colorScheme.onSurface,
                             ),
                           ),
                           const SizedBox(height: 6),
                           Text(
                             page.caption,
                             style: TextStyle(
                               fontSize: 13,
                               color: Theme.of(context).colorScheme.primary,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                           const SizedBox(height: 14),
                          Text(
                            page.subtitle,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: PageIndicator(
                          isActive: index == _currentPageIndex,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onNext(),
                      child: Text(
                        _currentPageIndex == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
