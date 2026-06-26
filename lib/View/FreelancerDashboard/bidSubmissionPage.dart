// lib/View/FreelancerDashboard/BidSubmissionPage.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/viewmodel/Bloc/bidBloc.dart';
import 'package:super_project/viewmodel/Events/bidEvents.dart';
import 'package:super_project/viewmodel/States/bidStates.dart';

class BidSubmissionPage extends StatefulWidget {
  final ProjectModel project;
  const BidSubmissionPage({super.key, required this.project});

  @override
  State<BidSubmissionPage> createState() => _BidSubmissionPageState();
}

class _BidSubmissionPageState extends State<BidSubmissionPage> {
  final _bidAmountController = TextEditingController();
  final _durationController = TextEditingController();
  final _coverLetterController = TextEditingController();

  void _onSubmit() {
    final amount = double.tryParse(_bidAmountController.text.trim());
    final duration = _durationController.text.trim();
    final coverLetter = _coverLetterController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (amount == null || duration.isEmpty || coverLetter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    context.read<BidBloc>().add(
      SubmitBidRequested(
        projectId: widget.project.projectId,
        projectTitle: widget.project.title, // ADD THIS
        freelancerId: currentUser!.uid,
        freelancerName: currentUser.displayName ?? 'Freelancer',
        bidAmount: amount,
        estimatedDuration: duration,
        coverLetter: coverLetter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Submit Bid',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BidBloc, BidState>(
        listener: (context, state) {
          if (state is BidSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bid submitted successfully!'),
                backgroundColor: Color(0xFF5B67F1),
              ),
            );
            Navigator.pop(context); // back to project details
          }
          if (state is BidFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is BidLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B67F1).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.work_outline,
                        color: Color(0xFF5B67F1),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.project.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B67F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bid Amount
                const Text(
                  'Your Bid Amount (₹)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bidAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. ${widget.project.budget.toStringAsFixed(0)}',
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
                    prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                  ),
                ),
                const SizedBox(height: 20),

                // Estimated Duration
                const Text(
                  'Estimated Duration',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    hintText: 'e.g. 2 Weeks',
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
                    prefixIcon: const Icon(Icons.schedule_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 20),

                // Cover Letter
                const Text(
                  'Cover Letter',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _coverLetterController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        'Explain why you are the best fit for this project...',
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
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B67F1),
                      disabledBackgroundColor: const Color(
                        0xFF5B67F1,
                      ).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text(
                              'Submit Bid',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bidAmountController.dispose();
    _durationController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }
}
