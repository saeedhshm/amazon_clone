import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../widgets/amazon_bottom_nav_bar.dart';
import '../../../../constants/app_colors.dart';
import '../../../../widgets/amazon_button.dart';
import '../../data/models/user_model.dart';
import '../../../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  UserModel? _user;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    // For development, use mock data
    // In production, use: await _userService.getUserData();
    _user = _userService.getMockUserData();
    
    if (_user != null) {
      _emailController.text = _user!.email;
      _nameController.text = _user!.name;
      _phoneController.text = _user!.phoneNumber ?? '';
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _updateProfile() async {
    try {
      final success = await _userService.updateUserProfile(
        name: _nameController.text,
      );
      
      if (success) {
        // Refresh user data
        await _loadUserData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile_updated_successfully'.tr())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_update_profile'.tr())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'error_updating_profile'.tr()}: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'error_signing_out'.tr()}: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AmazonAppBar(
        title: 'your_account'.tr(),
        showSearchBar: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfileForm(),
              const SizedBox(height: 24),
              _buildAccountOptions(),
              const SizedBox(height: 24),
              _buildSignOutButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AmazonBottomNavBar(currentIndex: 3),
    );
  }
  
  Widget _buildProfileHeader() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (_user?.profileImageUrl != null)
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(_user!.profileImageUrl!),
              )
            else
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 30),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'hello'.tr()}, ${_user?.name ?? 'user'.tr()}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (_user?.isPrime == true)
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.amazonOrange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'prime_member'.tr(),
                          style: TextStyle(color: AppColors.amazonOrange),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildProfileForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'personal_information'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'name'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'email'.tr(),
                border: const OutlineInputBorder(),
                enabled: false, // Email update requires re-authentication
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'phone_number'.tr(),
                border: const OutlineInputBorder(),
                enabled: false, // Phone update requires verification
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            AmazonButton(
              text: 'update_profile'.tr(),
              onPressed: _updateProfile,
              buttonType: AmazonButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccountOptions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'account_options'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              'your_orders'.tr(),
              'track_return_buy'.tr(),
              Icons.shopping_bag_outlined,
              () {},
            ),
            const Divider(),
            _buildOptionTile(
              'your_addresses'.tr(),
              'manage_shipping_addresses'.tr(),
              Icons.location_on_outlined,
              () {
                Navigator.pushNamed(context, '/addresses');
              },
            ),
            const Divider(),
            _buildOptionTile(
              'payment_options'.tr(),
              'manage_payment_methods'.tr(),
              Icons.payment_outlined,
              () {
                Navigator.pushNamed(context, '/payments');
              },
            ),
            const Divider(),
            _buildOptionTile(
              'prime_membership'.tr(),
              'view_benefits'.tr(),
              Icons.star_outline,
              () {},
            ),
            const Divider(),
            _buildLanguageOption(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageOption() {
    final currentLocale = context.locale;
    final isArabic = currentLocale.languageCode == 'ar';
    
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.amazonOrange),
      title: Text('language'.tr()),
      subtitle: Text(isArabic ? 'العربية' : 'English'),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('select_language'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageDialogOption(
                    dialogContext,
                    'English',
                    'en',
                    '🇺🇸',
                    !isArabic,
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageDialogOption(
                    dialogContext,
                    'العربية',
                    'ar',
                    '🇸🇦',
                    isArabic,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildLanguageDialogOption(
    BuildContext dialogContext,
    String label,
    String languageCode,
    String flag,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        context.setLocale(Locale(languageCode));
        Navigator.of(dialogContext).pop();
        
        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('language_changed'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryColor
                : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? AppColors.primaryColor
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.amazonOrange),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
  
  Widget _buildSignOutButton() {
    return AmazonButton(
      text: 'sign_out'.tr(),
      onPressed: _signOut,
      buttonType: AmazonButtonType.secondary,
      isFullWidth: true,
    );
  }
}