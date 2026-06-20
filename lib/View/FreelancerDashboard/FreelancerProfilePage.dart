// import 'package:flutter/material.dart';
// import 'FreelancerProfile.dart';

// class FreelancerProfile extends StatefulWidget {
//   const FreelancerProfile({super.key});

//   @override
//   State<FreelancerProfile> createState() => _FreelancerProfileState();
// }

// class _FreelancerProfileState extends State<FreelancerProfile> {
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   final double _progress = 0.25; // 25% for step 1 of 4

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     super.dispose();
//   }

//   void _nextStep() {
//     if (_formKey.currentState!.validate()) {
//       // Handle next step
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Moving to next step...'),
//           backgroundColor: Color(0xFF5B67F1),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Complete Your Profile',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Progress Bar Section
//             Container(
//               color: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: Row(
//                 children: [
//                   // Step indicator
//                   Container(
//                     width: 32,
//                     height: 32,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF5B67F1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Center(
//                       child: Text(
//                         '1',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   // Progress bar
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: LinearProgressIndicator(
//                         value: _progress,
//                         minHeight: 8,
//                         backgroundColor: Colors.grey[200],
//                         valueColor: const AlwaysStoppedAnimation<Color>(
//                           Color(0xFF5B67F1),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   // Step count
//                   Text(
//                     '4',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Form Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 8),

//                     // Section Title
//                     const Text(
//                       'Personal Details',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     // Description
//                     Text(
//                       'Let\'s start with your basic information to personalize your CampusGigs experience.',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[600],
//                         height: 1.5,
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // First Name
//                     const Text(
//                       'First Name',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     TextFormField(
//                       controller: _firstNameController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g., Anjali',
//                         hintStyle: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 14,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(
//                             color: Color(0xFF5B67F1),
//                             width: 2,
//                           ),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(color: Colors.red),
//                         ),
//                         focusedErrorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(
//                             color: Colors.red,
//                             width: 2,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 14,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your first name';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     // Last Name
//                     const Text(
//                       'Last Name',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     TextFormField(
//                       controller: _lastNameController,
//                       decoration: InputDecoration(
//                         hintText: 'e.g., Sharma',
//                         hintStyle: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 14,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(
//                             color: Color(0xFF5B67F1),
//                             width: 2,
//                           ),
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(color: Colors.red),
//                         ),
//                         focusedErrorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(
//                             color: Colors.red,
//                             width: 2,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 14,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your last name';
//                         }
//                         return null;
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Next Step Button
//             Container(
//               padding: const EdgeInsets.all(20),
//               color: Colors.grey[50],
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return ProfilePage();
//                         },
//                       ),
//                     );
//                     _nextStep;
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5B67F1),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Next Step',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
