import 'package:flutter/material.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../constants/app_colors.dart';
import '../../../../widgets/amazon_button.dart';
import '../../../../services/user_service.dart';
import '../../data/models/user_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final UserService _userService = UserService();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  
  UserModel? _user;
  bool _isLoading = true;
  List<String> _paymentMethods = [];
  
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });
    
    // For development, use mock data
    // In production, use: _user = await _userService.getUserData();
    _user = _userService.getMockUserData();
    
    if (_user != null) {
      setState(() {
        _paymentMethods = List.from(_user!.paymentMethods);
        _isLoading = false;
      });
    } else {
      setState(() {
        _paymentMethods = [];
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addPaymentMethod() async {
    if (_cardNumberController.text.trim().isEmpty ||
        _cardHolderController.text.trim().isEmpty ||
        _expiryController.text.trim().isEmpty ||
        _cvvController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    
    // Mask the card number for security
    final String lastFourDigits = _cardNumberController.text.substring(_cardNumberController.text.length - 4);
    final String cardType = _getCardType(_cardNumberController.text);
    final String maskedCard = '$cardType ending in $lastFourDigits';
    
    // In production, use: await _userService.addPaymentMethod(maskedCard);
    setState(() {
      _paymentMethods.add(maskedCard);
      _cardNumberController.clear();
      _cardHolderController.clear();
      _expiryController.clear();
      _cvvController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment method added successfully')),
    );
  }
  
  String _getCardType(String cardNumber) {
    // Very basic card type detection
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith('5')) {
      return 'Mastercard';
    } else if (cardNumber.startsWith('3')) {
      return 'Amex';
    } else if (cardNumber.startsWith('6')) {
      return 'Discover';
    } else {
      return 'Card';
    }
  }
  
  Future<void> _removePaymentMethod(String paymentMethod) async {
    // In production, use: await _userService.removePaymentMethod(paymentMethod);
    setState(() {
      _paymentMethods.remove(paymentMethod);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment method removed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AmazonAppBar(
        title: 'Your Payment Options',
        showSearchBar: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddPaymentForm(),
                  const SizedBox(height: 24),
                  Text(
                    'Your Payment Methods',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodsList(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildAddPaymentForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a New Payment Method',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: 'XXXX XXXX XXXX XXXX',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 16,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cardHolderController,
              decoration: const InputDecoration(
                labelText: 'Card Holder Name',
                hintText: 'John Doe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    maxLength: 5,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: 'XXX',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AmazonButton(
              text: 'Add Payment Method',
              onPressed: _addPaymentMethod,
              buttonType: AmazonButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodsList() {
    if (_paymentMethods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No payment methods saved yet.'),
        ),
      );
    }
    
    return Expanded(
      child: ListView.builder(
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          final paymentMethod = _paymentMethods[index];
          final bool isVisa = paymentMethod.contains('Visa');
          final bool isMastercard = paymentMethod.contains('Mastercard');
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: Icon(
                isVisa ? Icons.credit_card : (isMastercard ? Icons.credit_card : Icons.payment),
                color: isVisa ? Colors.blue : (isMastercard ? Colors.red : AppColors.amazonOrange),
              ),
              title: Text(paymentMethod),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removePaymentMethod(paymentMethod),
              ),
            ),
          );
        },
      ),
    );
  }
}