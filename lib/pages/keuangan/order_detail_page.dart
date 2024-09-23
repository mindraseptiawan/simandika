import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/services/order_service.dart';
import 'package:provider/provider.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

class OrderDetailPage extends StatefulWidget {
  final int? orderId;

  const OrderDetailPage({super.key, this.orderId});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderModel> _orderDetails;
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _paymentProofPath;
  String? _selectedPaymentMethod = 'cash';
  final TextEditingController _paymentProofController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;

    if (widget.orderId == null) {
      setState(() {
        _errorMessage = 'Invalid order ID';
        _isLoading = false;
      });
      return;
    }

    try {
      final orderService = OrderService();
      final order = await orderService.getOrderById(widget.orderId!, token!);
      setState(() {
        _orderDetails = Future.value(order);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setPricePerUnit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;
    final pricePerUnit = double.tryParse(_priceController.text) ?? 0.0;

    try {
      final orderService = OrderService();
      debugPrint(
          "Processing order: ${widget.orderId} with price: $pricePerUnit");
      final success = await orderService.setPricePerUnit(
          widget.orderId!, pricePerUnit, token!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price Set successfully')),
        );
        Navigator.pop(context, true);
        _fetchOrderDetails();
      }
    } catch (e) {
      debugPrint("Error set price order: $e");
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;

    try {
      final orderService = OrderService();
      final success = await orderService.processOrder(widget.orderId!, token!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order processed successfully')),
        );
        Navigator.pop(context, true);
        _fetchOrderDetails();
      }
    } catch (e) {
      debugPrint("Error processing order: $e");
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPaymentProof() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;

    try {
      final orderService = OrderService();
      final success = await orderService.submitPaymentProof(
          widget.orderId!, _selectedPaymentMethod!, _paymentProofPath, token!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment proof submitted successfully')),
        );
        _fetchOrderDetails();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;

    try {
      final orderService = OrderService();
      final success = await orderService.verifyPayment(widget.orderId!, token!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment verified successfully')),
        );
        _fetchOrderDetails();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _paymentProofPath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderId != null ? 'Order Details' : 'Invalid Order'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : widget.orderId == null
                  ? const Center(child: Text('Invalid order ID'))
                  : FutureBuilder<OrderModel>(
                      future: _orderDetails,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData) {
                          return const Center(
                              child: Text('No order details available'));
                        }

                        final order = snapshot.data!;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order ID: ${order.id}',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              Text('Status: ${order.status}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text('Quantity: ${order.quantity}',
                                  style: Theme.of(context).textTheme.bodyLarge),
                              Text('Address: ${order.alamat}',
                                  style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(height: 20),
                              if (order.status == 'pending') ...[
                                TextField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                      labelText: 'Price per Unit'),
                                  keyboardType: TextInputType.number,
                                ),
                                ElevatedButton(
                                  onPressed: _setPricePerUnit,
                                  child: const Text('Process Order'),
                                ),
                              ] else if (order.status == 'price_set') ...[
                                ElevatedButton(
                                  onPressed: _processOrder,
                                  child: const Text('Processed Order'),
                                ),
                              ] else if (order.status ==
                                  'awaiting_payment') ...[
                                const SizedBox(height: 20),
                                DropdownButton<String>(
                                  value: _selectedPaymentMethod,
                                  items: ['cash', 'transfer']
                                      .map((method) => DropdownMenuItem<String>(
                                            value: method,
                                            child: Text(method.capitalize!),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethod = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _paymentProofController,
                                  decoration: InputDecoration(
                                    labelText: 'Payment Proof (Optional)',
                                    helperText: _selectedPaymentMethod ==
                                            'transfer'
                                        ? 'Recommended for transfer payments'
                                        : 'Optional for cash payments',
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  child: const Text('Pick Payment Proof Image'),
                                ),
                                if (_paymentProofPath != null)
                                  Text('Image selected: $_paymentProofPath'),
                                ElevatedButton(
                                  onPressed: _submitPaymentProof,
                                  child: const Text('Submit Payment'),
                                ),
                              ] else if (order.status ==
                                  'payment_verification') ...[
                                Text('Payment Method: ${order.paymentMethod}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                Text(
                                    'Payment Proof: ${order.paymentProof ?? "tidak ada Dokumen"}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                ElevatedButton(
                                  onPressed: _verifyPayment,
                                  child: const Text('Verify Payment'),
                                ),
                              ] else if (order.status == 'completed') ...[
                                Text(
                                    'Payment Verified At: ${order.paymentVerifiedAt}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                Text('Verified By: ${order.paymentVerifiedBy}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
