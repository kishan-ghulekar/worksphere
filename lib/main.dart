import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/View/SplashScreen.dart';
import 'package:super_project/repository/authRepository.dart';
import 'package:super_project/repository/bidRepository.dart';
import 'package:super_project/repository/clientRepository.dart';
import 'package:super_project/repository/contractRepository.dart';
import 'package:super_project/repository/freelancerRepository.dart';
import 'package:super_project/repository/projectRepository.dart';
import 'package:super_project/viewmodel/Bloc/authBloc.dart';
import 'package:super_project/viewmodel/Bloc/bidBloc.dart';
import 'package:super_project/viewmodel/Bloc/clientbloc.dart';
import 'package:super_project/viewmodel/Bloc/contractBloc.dart';
import 'package:super_project/viewmodel/Bloc/freelancerProfileBloc.dart';
import 'package:super_project/viewmodel/Bloc/projectBloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
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
        BlocProvider(
          create: (context) => ClientProfileBloc(ClientRepository()),
        ),
        BlocProvider(
          create: (context) => ContractBloc(ContractRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
