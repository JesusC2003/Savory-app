import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🌿 OnboardingPage (con animaciones suaves)
/// Muestra ilustraciones SVG o PNG con transiciones suaves tipo fade-in.
/// Solo se muestra la primera vez que el usuario abre la app Savory.
/// Autor: Jesús Castillo

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 🔹 Contenido del onboarding
  final List<Map<String, String>> _pages = [
    {
      "image": "assets/onboarding/step1.svg",
      "title": "Organiza tu despensa",
      "description":
          "Administra fácilmente los ingredientes que tienes y evita desperdicios. ¡Ahorra tiempo y dinero!"
    },
    {
      "image": "assets/onboarding/step2.svg",
      "title": "Descubre recetas deliciosas",
      "description":
          "Encuentra recetas personalizadas según los ingredientes que ya tienes en casa."
    },
    {
      "image": "assets/onboarding/step3.svg",
      "title": "Aprovecha al máximo tu cocina",
      "description":
          "Convierte tu despensa en tu mejor aliada. ¡Comienza a disfrutar de cocinar con Savory!"
    },
  ];

  @override
  void initState() {
    super.initState();

    //  Controlador de animación (1 segundo por transición)
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    // Definición de animaciones (fade + slide)
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Iniciar animación al cargar la primera página
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Soporte SVG / PNG
  Widget _buildImage(String path) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        height: 250,
        placeholderBuilder: (context) =>
            const CircularProgressIndicator(color: Color(0xFF47A72F)),
      );
    } else {
      return Image.asset(
        path,
        height: 250,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 80, color: Colors.red),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Botón Saltar
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  "Saltar",
                  style: TextStyle(
                    color: Color(0xFF47A72F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 🔹 Contenido animado principal
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildImage(page["image"]!),
                            const SizedBox(height: 40),
                            Text(
                              page["title"]!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF47A72F),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              page["description"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Indicadores (puntitos)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  height: 10,
                  width: _currentPage == index ? 25 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF47A72F)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            // 🔹 Botón inferior
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF47A72F),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _currentPage == _pages.length - 1
                      ? "Comenzar"
                      : "Siguiente",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
