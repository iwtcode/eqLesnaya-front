import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/datasources/waiting_screen_remote_data_source.dart';
import 'data/repositories/waiting_screen_repository_impl.dart';
import 'domain/repositories/waiting_screen_repository.dart';
import 'domain/usecases/get_waiting_screen_data.dart';
import 'presentation/blocs/waiting_screen_bloc.dart';
import 'presentation/pages/waiting_screen_page.dart';

// --- ИСПРАВЛЕНИЕ: Файл был полностью восстановлен до корректного состояния ---
// Убрана вся старая логика маршрутизации, страница выбора кабинета и синтаксические ошибки.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final WaitingScreenRemoteDataSource remoteDataSource =
      WaitingScreenRemoteDataSourceImpl();
  final WaitingScreenRepository repository = WaitingScreenRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
  final GetWaitingScreenData getWaitingScreenData = GetWaitingScreenData(
    repository,
  );

  runApp(
    MyApp(getWaitingScreenData: getWaitingScreenData, repository: repository),
  );
}

class MyApp extends StatelessWidget {
  final GetWaitingScreenData getWaitingScreenData;
  final WaitingScreenRepository repository;

  const MyApp({
    super.key,
    required this.getWaitingScreenData,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Очередь в кабинеты',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1B4193),
          secondary: Color(0xFF2563EB),
          surface: Color(0xFFF8FAFC),
        ),
      ),
      home: BlocProvider(
        create: (context) => WaitingScreenBloc(
          getWaitingScreenData: getWaitingScreenData,
          repository: repository,
        ),
        child: const WaitingScreenPage(),
      ),
    );
  }
}
