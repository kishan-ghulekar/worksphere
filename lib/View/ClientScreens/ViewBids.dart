// lib/View/ClientScreens/ViewBids.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/model/bidModel.dart';
import 'package:super_project/model/projectModel.dart';
import 'package:super_project/viewmodel/Bloc/bidBloc.dart';
import 'package:super_project/viewmodel/Events/bidEvents.dart';
import 'package:super_project/viewmodel/States/bidStates.dart';

class ViewBidsPage extends StatefulWidget {
  final ProjectModel project;

  const ViewBidsPage({super.key, required this.project});

  @override
  State<ViewBidsPage> createState() => _ViewBidsPageState();
}

class _ViewBidsPageState extends State<ViewBidsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BidBloc>().add(LoadBidsForProject(widget.project.projectId));
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
        title: Text(
          widget.project.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BidBloc, BidState>(
        builder: (context, state) {
          if (state is BidLoading || state is BidInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BidFailure) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final bids =
              state is BidsForProjectLoaded ? state.bids : <BidModel>[];

          if (bids.isEmpty) {
            return const Center(
              child: Text(
                'No bids yet.\nFreelancers will appear here once they submit proposals.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bids.length,
            itemBuilder: (context, index) {
              return BidCard(
                bid: bids[index],
                project: widget.project,
              );
            },
          );
        },
      ),
    );
  }
}

class BidCard extends StatelessWidget {
  final BidModel bid;
  final ProjectModel project;

  const BidCard({super.key, required this.bid, required this.project});

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF00BFA5);
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF5B67F1).withOpacity(0.15),
                child: Text(
                  bid.freelancerName.isNotEmpty
                      ? bid.freelancerName[0].toUpperCase()
                      : 'F',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B67F1),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.freelancerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Submitted ${_timeAgo(bid.createdAt)}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(bid.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bid.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(bid.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bid amount and duration
          Row(
            children: [
              _infoChip(Icons.currency_rupee,
                  '₹${bid.bidAmount.toStringAsFixed(0)}'),
              const SizedBox(width: 12),
              _infoChip(Icons.schedule, bid.estimatedDuration),
            ],
          ),
          const SizedBox(height: 12),

          // Cover Letter
          Text(
            'Cover Letter',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            bid.coverLetter,
            style: TextStyle(
                fontSize: 13, color: Colors.grey[700], height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Action Buttons — only show Hire if still pending
          if (bid.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hire Freelancer'),
                          content: Text(
                            'Are you sure you want to hire ${bid.freelancerName}? All other bids will be rejected.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<BidBloc>().add(
                                      AcceptBidRequested(
                                        bidId: bid.bidId,
                                        projectId: project.projectId,
                                      ),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B67F1),
                              ),
                              child: const Text('Hire',
                                  style:
                                      TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B67F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Hire',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Chat',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5B67F1),
                      side: const BorderSide(color: Color(0xFF5B67F1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}