import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../providers/cart_providers.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../../core/utils/result.dart';
import '../../../../widgets/amazon_app_bar.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final _addressFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Payment form controllers
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  String _selectedPaymentMethod = 'Credit Card';
  bool _savePaymentInfo = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartResult = ref.watch(cartProvider);
    
    return cartResult.fold(
      onSuccess: (cart) {
        return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AmazonAppBar(
          showSearchBar: false,
          title: 'Checkout',
          cartItemCount: cart.itemCount,
        ),
        body: Column(
          children: [
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0) {
                  if (_addressFormKey.currentState!.validate()) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                } else if (_currentStep == 1) {
                  if (_paymentFormKey.currentState!.validate()) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                } else if (_currentStep == 2) {
                  _placeOrder(context);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              steps: [
                Step(
                  title: Text('shipping_address'.tr()),
                  content: _buildAddressForm(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: Text('payment_method'.tr()),
                  content: _buildPaymentForm(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: Text('review_order'.tr()),
                  content: _buildOrderReview(cart),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
          ),
        ],
        ),
      );
      },
      onError: (failure) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AmazonAppBar(
          showSearchBar: false,
          title: 'checkout'.tr(),
          cartItemCount: 0,
        ),
        body: Center(child: Text('${'error'.tr()}: ${failure.message}')),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Form(
      key: _addressFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'full_name'.tr(),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressLine1Controller,
            decoration: InputDecoration(
              labelText: 'address_line_1'.tr(),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressLine2Controller,
            decoration: InputDecoration(
              labelText: 'address_line_2'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'city'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'state'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your state';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _zipCodeController,
                  decoration: InputDecoration(
                    labelText: 'zip_code'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ZIP code';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'phone_number'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text('save_address'.tr()),
            value: true,
            onChanged: (value) {},
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _paymentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('select_payment_method'.tr(), style: AppTextStyles.heading),
          const SizedBox(height: 16),
          _buildPaymentMethodSelector(),
          const SizedBox(height: 24),
          if (_selectedPaymentMethod == 'Credit Card') ...[  
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'card_number'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNameController,
              decoration: InputDecoration(
                labelText: 'card_name'.tr(),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the name on your card';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryDateController,
                    decoration: InputDecoration(
                      labelText: 'expiry_date'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expiry date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'cvv'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter CVV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text('save_payment_method'.tr()),
              value: _savePaymentInfo,
              onChanged: (value) {
                setState(() {
                  _savePaymentInfo = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.credit_card),
              const SizedBox(width: 8),
              Text('credit_card'.tr()),
            ],
          ),
          value: 'Credit Card',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.account_balance),
              const SizedBox(width: 8),
              Text('amazon_pay'.tr()),
            ],
          ),
          value: 'Amazon Pay',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.money),
              const SizedBox(width: 8),
              Text('pay_on_delivery'.tr()),
            ],
          ),
          value: 'Pay on Delivery',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOrderReview(CartEntity cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('shipping_address'.tr(), style: AppTextStyles.heading),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nameController.text.isNotEmpty ? _nameController.text : 'John Doe'),
                const SizedBox(height: 4),
                Text(_addressLine1Controller.text.isNotEmpty ? _addressLine1Controller.text : '123 Main St'),
                if (_addressLine2Controller.text.isNotEmpty) ...[  
                  const SizedBox(height: 4),
                  Text(_addressLine2Controller.text),
                ],
                const SizedBox(height: 4),
                Text('${_cityController.text.isNotEmpty ? _cityController.text : 'New York'}, ${_stateController.text.isNotEmpty ? _stateController.text : 'NY'} ${_zipCodeController.text.isNotEmpty ? _zipCodeController.text : '10001'}'),
                const SizedBox(height: 4),
                Text('Phone: ${_phoneController.text.isNotEmpty ? _phoneController.text : '(555) 123-4567'}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('payment_method'.tr(), style: AppTextStyles.heading),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _selectedPaymentMethod == 'Credit Card'
                      ? Icons.credit_card
                      : _selectedPaymentMethod == 'Amazon Pay'
                          ? Icons.account_balance
                          : Icons.money,
                ),
                const SizedBox(width: 16),
                Text(_selectedPaymentMethod),
                if (_selectedPaymentMethod == 'Credit Card' && _cardNumberController.text.isNotEmpty) ...[  
                  const Spacer(),
                  Text('**** ${_cardNumberController.text.substring(max(0, _cardNumberController.text.length - 4))}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('order_summary'.tr(), style: AppTextStyles.heading),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'items'.tr()} (${cart.itemCount}):', style: AppTextStyles.bodyMedium),
                    Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'shipping_handling'.tr()}:', style: AppTextStyles.bodyMedium),
                    Text(
                      cart.shippingCost == 0
                          ? 'FREE'
                          : '\$${cart.shippingCost.toStringAsFixed(2)}',
                      style: cart.shippingCost == 0
                          ? AppTextStyles.bodyMediumBold.copyWith(color: AppColors.success)
                          : AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'tax'.tr()}:', style: AppTextStyles.bodyMedium),
                    Text('\$${cart.tax.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'order_total'.tr()}:', style: AppTextStyles.bodyMediumBold),
                    Text('\$${cart.grandTotal.toStringAsFixed(2)}', style: AppTextStyles.heading),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _placeOrder(BuildContext context) {
    // In a real app, we would process the order here
    // For now, we'll just show a success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('order_placed_successfully'.tr()),
        content: Text('order_confirmation_message'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              // Clear cart and navigate to home
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }
}

// Helper function for string manipulation
int max(int a, int b) {
  return a > b ? a : b;
}