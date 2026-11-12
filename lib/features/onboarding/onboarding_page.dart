import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/buttons/app_primary_button.dart';
import '../../shared/widgets/buttons/app_text_button.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Données représentatives d'une slide d'onboarding.
class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.mainIcon,
    required this.badgeIcons,
  });

  final String title;
  final String description;
  final IconData mainIcon;
  final List<IconData> badgeIcons;
}

/// Écran d'Onboarding de LOBOKO.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      title: 'Trouvez le bon prestataire',
      description:
          'Découvrez des professionnels qualifiés près de chez vous pour répondre à tous vos besoins du quotidien à Brazzaville.',
      mainIcon: Icons.search_rounded,
      badgeIcons: [
        Icons.handyman_rounded,
        Icons.location_on_rounded,
        Icons.verified_user_rounded,
      ],
    ),
    _OnboardingSlideData(
      title: 'Réservez en toute simplicité',
      description:
          'Consultez les prestations, échangez directement avec les professionnels et organisez vos rendez-vous rapidement.',
      mainIcon: Icons.event_available_rounded,
      badgeIcons: [
        Icons.calendar_month_rounded,
        Icons.chat_bubble_outline_rounded,
        Icons.check_circle_outline_rounded,
      ],
    ),
    _OnboardingSlideData(
      title: 'Développez votre activité',
      description:
          'Vous proposez des services ? Présentez vos compétences, développez votre clientèle et trouvez de nouvelles opportunités.',
      mainIcon: Icons.trending_up_rounded,
      badgeIcons: [
        Icons.work_outline_rounded,
        Icons.workspace_premium_rounded,
        Icons.payments_outlined,
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.animationNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.profileSelection);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barre supérieure : Bouton Retour & Bouton Passer
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing2,
                vertical: AppConstants.spacing2,
              ),
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      AppBackButton(
                        onPressed: _previousPage,
                        tooltip: 'Page précédente',
                      )
                    else
                      const SizedBox(width: 48),
                    if (!isLastPage)
                      AppTextButton(
                        label: 'Passer',
                        onPressed: _finishOnboarding,
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Carrousel de slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: AppConstants.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Zone visuelle d'illustration
                        _buildIllustration(slide),
                        const SizedBox(height: AppConstants.spacing8),

                        // Titre de la slide
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 26,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing3),

                        // Description de la slide
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Zone inférieure : Indicateurs & Bouton d'action
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacing4,
                0,
                AppConstants.spacing4,
                AppConstants.spacing6,
              ),
              child: Column(
                children: [
                  // Indicateurs de progression (dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: AppConstants.animationFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? AppColors.primary
                              : AppColors.disabledBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing6),

                  // Bouton principal d'action
                  AppPrimaryButton(
                    label: isLastPage ? 'Commencer' : 'Continuer',
                    icon: isLastPage ? Icons.arrow_forward_rounded : null,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit une illustration vectorielle propre et moderne sans images distantes.
  Widget _buildIllustration(_OnboardingSlideData slide) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle d'arrière-plan principal
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGreen,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                slide.mainIcon,
                size: 72,
                color: AppColors.primary,
              ),
            ),
          ),

          // Badges secondaires disposés autour du cercle principal
          Positioned(
            top: 16,
            left: 36,
            child: _buildBadgeIcon(slide.badgeIcons[0]),
          ),
          Positioned(
            top: 24,
            right: 36,
            child: _buildBadgeIcon(slide.badgeIcons[1]),
          ),
          Positioned(
            bottom: 16,
            right: 50,
            child: _buildBadgeIcon(slide.badgeIcons[2]),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.gold,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 22,
        color: AppColors.primary,
      ),
    );
  }
}
