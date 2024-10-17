import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simandika/models/kandang_model.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/services/kandang_service.dart';
import 'package:simandika/services/order_service.dart';
import 'package:provider/provider.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/customSnackbar_widget.dart';

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

  final statusMap = {
    'awaiting_payment': 'Awaiting Payment',
    'payment_verification': 'Verification Payment',
    'pending': 'Pending',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

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
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        showCustomSnackBar(context, 'Set Harga Sukses!', SnackBarType.success);
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
          showCustomSnackBar(
              context, 'Order processed successfully', SnackBarType.success);
          Navigator.pop(context, true);
          _fetchOrderDetails();
        }
      } catch (e) {
        if (e.toString() == 'Stock in kandang is insufficient') {
          showCustomSnackBar(
              context, 'Stock in kandang is insufficient', SnackBarType.error);
        } else {
          showCustomSnackBar(
              context, 'Stock dikandang tidak cukup', SnackBarType.error);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Handle the case where _selectedKandang is null

      showCustomSnackBar(
          context, 'Please select a kandang', SnackBarType.error);
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
        showCustomSnackBar(context, 'Payment proof submitted successfully',
            SnackBarType.success);
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
        showCustomSnackBar(
            context, 'Payment verified successfully', SnackBarType.success);
        Navigator.pop(context, true);
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
          showCustomSnackBar(
              context, 'Order cancelled successfully', SnackBarType.success);
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
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: const Text('Detail Order',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
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
                        return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                                elevation: 4,
                                color: primaryColor,
                                child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                              'Order ID', '#${order.id}'),
                                          _buildDetailRow('Customer',
                                              '${order.customer?.name}'),
                                          _buildDetailRow(
                                            'Status',
                                            statusMap[order.status] ??
                                                order.status,
                                          ),
                                          _buildDetailRow(
                                              'Quantity', '${order.quantity}'),
                                          _buildDetailRow(
                                              'Address', '${order.alamat}'),
                                          const SizedBox(height: 20),
                                          if (order.status == 'pending') ...[
                                            TextField(
                                              controller: _priceController,
                                              decoration: const InputDecoration(
                                                  labelText: 'Price per Unit'),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            ElevatedButton(
                                              onPressed: _setPricePerUnit,
                                              child:
                                                  const Text('Set Order Price'),
                                            ),
                                          ] else if (order.status ==
                                              'price_set') ...[
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Select Kandang: ',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                DropdownButton(
                                                  value: _selectedKandang,
                                                  items: _kandangList
                                                      .where((kandang) =>
                                                          kandang.status ==
                                                          true)
                                                      .map((kandang) =>
                                                          DropdownMenuItem(
                                                            value: kandang.id,
                                                            child: Text(
                                                                '${kandang.namaKandang} (${kandang.jumlahReal}/${kandang.kapasitas})',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black)),
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
                                              child: const Text('Process Order',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          ] else if (order.status ==
                                              'awaiting_payment') ...[
                                            const SizedBox(height: 20),
                                            DropdownButton<String>(
                                              value: _selectedPaymentMethod,
                                              items: ['cash', 'transfer']
                                                  .map((method) =>
                                                      DropdownMenuItem<String>(
                                                        value: method,
                                                        child: Text(
                                                            method.capitalize!,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedPaymentMethod =
                                                      value;
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            TextField(
                                              controller:
                                                  _paymentProofController,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      'Payment Proof (Optional)',
                                                  labelStyle: const TextStyle(
                                                      color: Colors.white),
                                                  helperText: _selectedPaymentMethod ==
                                                          'transfer'
                                                      ? 'Recommended for transfer payments'
                                                      : 'Optional for cash payments',
                                                  helperStyle: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            ElevatedButton(
                                              onPressed: _pickImage,
                                              child: const Text(
                                                  'Pick Payment Proof Image',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                            ),
                                            if (_paymentProofPath != null)
                                              Text(
                                                  'Image selected: $_paymentProofPath'),
                                            ElevatedButton(
                                              onPressed: _submitPaymentProof,
                                              child: const Text(
                                                  'Submit Payment',
                                                  style: const TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          ] else if (order.status ==
                                              'payment_verification') ...[
                                            Text(
                                                'Payment Method: ${order.paymentMethod}',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            Text(
                                                'Payment Proof: ${order.paymentProof ?? "tidak ada Dokumen"}',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            ElevatedButton(
                                              onPressed: _verifyPayment,
                                              child:
                                                  const Text('Verify Payment'),
                                            ),
                                          ] else if (order.status ==
                                              'completed') ...[
                                            Text(
                                                'Payment Verified At: ${order.paymentVerifiedAt}',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            Text(
                                                'Verified By: ${order.paymentVerifiedBy}',
                                                style: const TextStyle(
                                                    color: Colors.white)),
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
                                    ))));
                      },
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
