import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontSize: 14.0,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    color: AppColors.textSecondary,
  );
  
  // Button text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // Price text
  static const TextStyle priceRegular = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  // Price text
  static const TextStyle priceText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  // Price text
  static const TextStyle originalPriceText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle priceDiscount = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.dealColor,
  );
  
  static const TextStyle priceStrikethrough = TextStyle(
    fontSize: 14.0,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );
  
  // Link text
  static const TextStyle link = TextStyle(
    fontSize: 14.0,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );
  
  // Product title
  static const TextStyle productTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  // Review text
  static const TextStyle reviewText = TextStyle(
    fontSize: 14.0,
    color: AppColors.textSecondary,
  );
  
  // Deal text
  static const TextStyle dealText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // Prime text
  static const TextStyle primeText = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.primeColor,
  );
}