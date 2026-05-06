import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Widgets réutilisables partagés entre tous les membres.
///
/// Ces composants suivent le design system Figma "Atelier Benin" :
/// - Ombres impressionnistes (blurRadius > 20)
/// - Coins arrondis 8px
/// - Typographie Newsreader / Be Vietnam Pro

/// Carte impressionniste avec ombre floue.
class ImpressionistCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  const ImpressionistCard({
    super.key,
    required this.child,
    this.padding,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        boxShadow: boxShadow ?? AppColors.shadowLight,
      ),
      child: child,
    );
  }
}

/// Indicateur de chargement stylisé.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 2,
        child: LinearProgressIndicator(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Message d'erreur stylisé.
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}

/// État vide stylisé.
class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.outline,
                ),
          ),
        ],
      ),
    );
  }
}
