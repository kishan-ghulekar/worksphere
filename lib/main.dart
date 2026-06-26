import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/View/SplashScreen.dart';
import 'package:super_project/repository/authRepository.dart';
import 'package:super_project/repository/bidRepository.dart';
import 'package:super_project/repository/freelancerRepository.dart';
import 'package:super_project/repository/projectRepository.dart';
import 'package:super_project/viewmodel/Bloc/authBloc.dart';
import 'package:super_project/viewmodel/Bloc/bidBloc.dart';
import 'package:super_project/viewmodel/Bloc/freelancerProfileBloc.dart';
import 'package:super_project/viewmodel/Bloc/projectBloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),

        BlocProvider(create: (_) => ProjectBloc(ProjectRepository())),

        BlocProvider(create: (context) => BidBloc(BidRepository())),

        BlocProvider(
          create: (context) => FreelancerProfileBloc(FreelancerRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
