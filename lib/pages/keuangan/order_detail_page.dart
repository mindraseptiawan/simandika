import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/services/kandang_service.dart';
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
  int? _selectedKandang;
  final TextEditingController _paymentProofController = TextEditingController();
  List<KandangModel> _kandangList = [];
  final KandangService _kandangService = KandangService();

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
    getKandangs();
  }

  Future<void> getKandangs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;

    try {
      List<KandangModel> kandangs = await _kandangService.getKandangs(token!);
      if (!mounted) return;
      setState(() {
        _kandangList = kandangs;
      });
    } catch (e) {
      if (mounted) {
        // Handle errors and refresh token if needed
        debugPrint('Failed to load kandangs: $e');
        // Optionally show a message or refresh token if needed
      }
    }
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

    if (_selectedKandang != null) {
      try {
        final orderService = OrderService();
        final success = await orderService.processOrder(
            token!, widget.orderId!, _selectedKandang!);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order processed successfully')),
          );
          Navigator.pop(context, true);
          _fetchOrderDetails();
        }
      } catch (e) {
        if (e.toString() == 'Stock in kandang is insufficient') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock in kandang is insufficient')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock dikandang tidak cukup')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Handle the case where _selectedKandang is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a kandang')),
      );
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
        Navigator.pop(context, true);
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
        Navigator.pop(context, true);
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

  Future<void> _cancelOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).user.token;

    // Show a dialog to confirm cancellation
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Apakah anda ingin membatalkan Order?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Kembalikan false jika klik Cancel
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true); // Kembalikan true jika klik OK
              },
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      try {
        final orderService = OrderService();
        final success = await orderService.cancelOrder(widget.orderId!, token!);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
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
                                  child: const Text('Set Order Price'),
                                ),
                              ] else if (order.status == 'price_set') ...[
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Text('Select Kandang: '),
                                    DropdownButton(
                                      value: _selectedKandang,
                                      items: _kandangList
                                          .where((kandang) =>
                                              kandang.status == true)
                                          .map((kandang) => DropdownMenuItem(
                                                value: kandang.id,
                                                child: Text(
                                                    '${kandang.namaKandang} (${kandang.jumlahReal}/${kandang.kapasitas})'),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedKandang = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: _processOrder,
                                  child: const Text('Process Order'),
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
                              const SizedBox(height: 20),
                              if (order.status != 'completed' &&
                                  order.status != 'cancelled')
                                ElevatedButton(
                                  onPressed: _cancelOrder,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Cancel Order'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
