import 'package:flutter/material.dart';
import '../../../../widgets/amazon_app_bar.dart';
import '../../../../widgets/amazon_button.dart';
import '../../../../services/user_service.dart';
import '../../data/models/user_model.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final UserService _userService = UserService();
  final TextEditingController _addressController = TextEditingController();
  
  UserModel? _user;
  bool _isLoading = true;
  List<String> _addresses = [];
  
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }
  
  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });
    
    // For development, use mock data
    // In production, use: _user = await _userService.getUserData();
    _user = _userService.getMockUserData();
    
    if (_user != null) {
      setState(() {
        _addresses = List.from(_user!.addresses);
        _isLoading = false;
      });
    } else {
      setState(() {
        _addresses = [];
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addAddress() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address')),
      );
      return;
    }
    
    // In production, use: await _userService.addAddress(_addressController.text);
    setState(() {
      _addresses.add(_addressController.text);
      _addressController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address added successfully')),
    );
  }
  
  Future<void> _removeAddress(String address) async {
    // In production, use: await _userService.removeAddress(address);
    setState(() {
      _addresses.remove(address);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address removed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AmazonAppBar(
        title: 'Your Addresses',
        showSearchBar: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddAddressForm(),
                  const SizedBox(height: 24),
                  Text(
                    'Your Addresses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildAddressList(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildAddAddressForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a New Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Full Address',
                hintText: 'Street, City, State, ZIP',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            AmazonButton(
              text: 'Add Address',
              onPressed: _addAddress,
              buttonType: AmazonButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddressList() {
    if (_addresses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No addresses saved yet.'),
        ),
      );
    }
    
    return Expanded(
      child: ListView.builder(
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              title: Text(address),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeAddress(address),
              ),
            ),
          );
        },
      ),
    );
  }
}