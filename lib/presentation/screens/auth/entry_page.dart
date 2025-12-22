import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';

/// Entry page - First screen users see
class EntryPage extends StatelessWidget {
  const EntryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo with gradient wave
              _buildLogo(context),
              const SizedBox(height: 24),
              // App name with brand typography
              Text(
                'PULSE',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
              ),
              const Spacer(flex: 3),
              // Get Started button
              PrimaryButton(
                text: 'Get started',
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.roleSelectionRoute);
                },
              ),
              const SizedBox(height: 16),
              // Login button (outlined)
              PrimaryButton(
                text: 'Login',
                isOutlined: true,
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.loginRoute);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient wave background
          CustomPaint(
            size: const Size(200, 200),
            painter: WavePainter(),
          ),
          // Logo icon representation (pulse wave)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.darkText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Wave icon
              Icon(
                Icons.graphic_eq,
                size: 80,
                color: AppColors.primary.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the wave background
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = AppColors.secondary.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.5);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.5,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.6,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
