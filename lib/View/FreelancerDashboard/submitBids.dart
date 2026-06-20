import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubmitBidPage extends StatefulWidget {
  const SubmitBidPage({super.key});

  @override
  State<SubmitBidPage> createState() => _SubmitBidPageState();
}

class _SubmitBidPageState extends State<SubmitBidPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bidAmountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _pitchController = TextEditingController();

  bool _bidAmountTouched = false;

  @override
  void dispose() {
    _bidAmountController.dispose();
    _durationController.dispose();
    _pitchController.dispose();
    super.dispose();
  }

  void _submitBid() {
    setState(() {
      _bidAmountTouched = true;
    });

    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bid submitted successfully!'),
          backgroundColor: Color(0xFF5B67F1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Submit Your Bid',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Bid Amount
              const Text(
                'Your Bid Amount (₹)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _bidAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'e.g., 5000',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _bidAmountTouched && _bidAmountController.text.isEmpty
                              ? Colors.red
                              : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _bidAmountTouched && _bidAmountController.text.isEmpty
                              ? Colors.red
                              : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          _bidAmountTouched && _bidAmountController.text.isEmpty
                              ? Colors.red
                              : const Color(0xFF5B67F1),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  errorStyle: const TextStyle(height: 0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_bidAmountTouched) {
                    setState(() {});
                  }
                },
              ),

              if (_bidAmountTouched && _bidAmountController.text.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Bid amount is required.',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),

              const SizedBox(height: 20),

              // Estimated Duration
              const Text(
                'Estimated Duration (Days)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'e.g., 7',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF5B67F1),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Your Pitch
              const Text(
                'Your Pitch',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _pitchController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Describe your approach, skills, and why\nyou\'re the best fit for this project...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF5B67F1),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B67F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Bid',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
