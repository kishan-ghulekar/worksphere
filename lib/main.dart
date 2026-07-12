import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_project/View/SplashScreen.dart';
import 'package:super_project/repository/authRepository.dart';
import 'package:super_project/repository/bidRepository.dart';
import 'package:super_project/repository/chatRepository.dart';
import 'package:super_project/repository/clientRepository.dart';
import 'package:super_project/repository/contractRepository.dart';
import 'package:super_project/repository/freelancerRepository.dart';
import 'package:super_project/repository/projectRepository.dart';
import 'package:super_project/viewmodel/Bloc/authBloc.dart';
import 'package:super_project/viewmodel/Bloc/bidBloc.dart';
import 'package:super_project/viewmodel/Bloc/chatBloc.dart';
import 'package:super_project/viewmodel/Bloc/clientbloc.dart';
import 'package:super_project/viewmodel/Bloc/contractBloc.dart';
import 'package:super_project/viewmodel/Bloc/freelancerProfileBloc.dart';
import 'package:super_project/viewmodel/Bloc/message_bloc.dart';
import 'package:super_project/viewmodel/Bloc/projectBloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (state == AppLifecycleState.resumed) {
      ChatRepository().setOnlineStatus(uid, true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ChatRepository().setOnlineStatus(uid, false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => ProjectBloc(ProjectRepository())),
        BlocProvider(create: (_) => BidBloc(BidRepository())),
        BlocProvider(
          create: (_) => FreelancerProfileBloc(FreelancerRepository()),
        ),
        BlocProvider(
          create: (_) => ClientProfileBloc(ClientRepository()),
        ),
        BlocProvider(create: (_) => ContractBloc(ContractRepository())),
        BlocProvider(create: (_) => ChatBloc(ChatRepository())),
        BlocProvider(create: (_) => MessageBloc(ChatRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}