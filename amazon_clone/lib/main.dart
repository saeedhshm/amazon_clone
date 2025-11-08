import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/splash_screen.dart';
import 'features/product/presentation/screens/product_detail_screen.dart';
import 'features/product/presentation/screens/product_listing_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/cart/presentation/screens/checkout_screen.dart';
import 'features/user/presentation/screens/profile_screen.dart';
import 'features/user/presentation/screens/address_screen.dart';
import 'features/user/presentation/screens/payment_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  // Initialize Firebase (optional - for backward compatibility with old services)
  // Since we're using mock data, this is not required but prevents errors
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase initialization failed - continue without it since we use mock data
    print('Firebase initialization skipped (using mock data): $e');
  }
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app_name'.tr(),
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/product-listing': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ProductListingScreen(
            category: args != null && args.containsKey('category') ? args['category'] as String? : null,
            searchQuery: args != null && args.containsKey('searchQuery') ? args['searchQuery'] as String? : null,
            title: args != null && args.containsKey('title') ? args['title'] as String? : null,
          );
        },
        '/product-detail': (context) {
          final productId = ModalRoute.of(context)?.settings.arguments as String?;
          return ProductDetailScreen(
            productId: productId ?? '',
          );
        },
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/addresses': (context) => const AddressScreen(),
        '/payments': (context) => const PaymentScreen(),
        '/search': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return SearchScreen(initialQuery: args != null && args.containsKey('query') ? args['query'] as String? : null);
        },
      },
    );
  }
}
