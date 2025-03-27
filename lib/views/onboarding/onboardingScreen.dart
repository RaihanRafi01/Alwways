import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:playground_02/constants/translations/app_translations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  // Define content for both languages
  final Map<String, List<Map<String, String>>> onboardingContent = {
    'en_US': [
      {
        'title': 'Welcome to',
        'subtitle': 'Start writing the story of your life and leave an eternal legacy.',
      },
      {
        'title': 'Turn your answers into chapters',
        'subtitle': 'Chat with Titi, our AI, or answer the questionnaire to bring your memories to life.',
      },
      {
        'title': 'Add images and customize',
        'subtitle': 'Make it unique: add photos and design a special cover.',
      },
      {
        'title': 'Start for free and discover more',
        'subtitle': 'Create the first chapters for free and unlock the full book if you like it.',
      },
    ],
    'es_ES': [
      {
        'title': 'Bienvenido a',
        'subtitle': 'Comienza a escribir la historia de tu vida y deja un legado eterno.',
      },
      {
        'title': 'Convierte tus respuestas en capítulos',
        'subtitle': 'Chatea con Titi, nuestra IA, o responde el cuestionario para dar vida a tus recuerdos.',
      },
      {
        'title': 'Añade imágenes y personaliza',
        'subtitle': 'Hazlo único: agrega fotos y diseña una portada especial.',
      },
      {
        'title': 'Comienza gratis y descubre más',
        'subtitle': 'Crea los primeros capítulos gratis y desbloquea el libro completo si te gusta.',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        backgroundColor: AppColors.appBackground,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {});
                  },
                  children: [
                    _buildPage(
                      true,
                      "assets/images/onboarding/onboarding_gif.gif",
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![0]['title']!,
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![0]['subtitle']!,
                    ),
                    _buildPage(
                      false,
                      "assets/images/onboarding/onboarding_2.png",
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![1]['title']!,
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![1]['subtitle']!,
                    ),
                    _buildPage(
                      false,
                      "assets/images/onboarding/onboarding_3.png",
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![2]['title']!,
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![2]['subtitle']!,
                    ),
                    _buildPage(
                      false,
                      "assets/images/onboarding/onboarding_4.png",
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![3]['title']!,
                      onboardingContent[Get.locale?.toString() ?? 'en_US']![3]['subtitle']!,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 4,
                  effect: const WormEffect(
                    dotWidth: 10.0,
                    dotHeight: 10.0,
                    activeDotColor: AppColors.appColor,
                    dotColor: AppColors.dotInactive,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: CustomButton(
                  text: Get.locale?.languageCode == 'es' ? 'Comenzar' : 'Get Started',
                  onPressed: () {
                    if (_pageController.page == 3) {
                      Get.offNamed(AppRoutes.login);
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  backgroundColor: AppColors.borderColor,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(bool showGif, String mediaPath, String text1, String text2) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          showGif
              ? Gif(
            image: AssetImage(mediaPath),
            autostart: Autostart.once,
          )
              : Image.asset(mediaPath, height: 390, width: 200),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible( // Add this
                child: Text(
                  text1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appColor,
                  ),
                ),
              ),
              if (showGif)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SvgPicture.asset('assets/images/app_name.svg'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.onboardingText,
            ),
          ),
        ],
      ),
    );
  }
}