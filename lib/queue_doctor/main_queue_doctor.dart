import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player_web/video_player_web.dart';
import 'package:elqueue/queue_reception/data/datasources/ad_display_remote_datasource.dart';
import 'package:elqueue/queue_reception/data/repositories/ad_display_repository_impl.dart';
import 'package:elqueue/queue_reception/domain/repositories/ad_display_repository.dart';
import 'package:elqueue/queue_reception/presentation/blocs/ad_display_bloc.dart';
import 'data/datasources/waiting_screen_remote_data_source.dart';
import 'data/repositories/waiting_screen_repository_impl.dart';
import 'domain/repositories/waiting_screen_repository.dart';
import 'domain/usecases/get_waiting_screen_data.dart';
import 'presentation/blocs/waiting_screen_bloc.dart';
import 'presentation/pages/waiting_screen_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    VideoPlayerPlugin();
  }
  await dotenv.load(fileName: ".env");

  final httpClient = http.Client();

  final WaitingScreenRemoteDataSource remoteDataSource =
      WaitingScreenRemoteDataSourceImpl(client: httpClient);
  final WaitingScreenRepository repository =
      WaitingScreenRepositoryImpl(remoteDataSource: remoteDataSource);
  final GetWaitingScreenData getWaitingScreenData =
      GetWaitingScreenData(repository);

  final adDisplayRepository = AdDisplayRepositoryImpl(
    dataSource: AdDisplayRemoteDataSource(client: httpClient),
  );

  runApp(MyApp(
    getWaitingScreenData: getWaitingScreenData,
    repository: repository,
    adDisplayRepository: adDisplayRepository, // Передаем репозиторий в MyApp
  ));
}

class MyApp extends StatelessWidget {
  final GetWaitingScreenData getWaitingScreenData;
  final WaitingScreenRepository repository;
  final AdDisplayRepository adDisplayRepository;

  const MyApp(
      {super.key,
      required this.getWaitingScreenData,
      required this.repository,
      required this.adDisplayRepository}); // Добавляем в конструктор

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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WaitingScreenBloc>(
            create: (context) => WaitingScreenBloc(
              getWaitingScreenData: getWaitingScreenData,
              repository: repository,
            ),
          ),
          BlocProvider<AdDisplayBloc>(
            create: (context) => AdDisplayBloc(repository: adDisplayRepository)
              // Запускаем загрузку рекламы для экрана 'queue_doctor'
              ..add(const FetchEnabledAds(screen: 'queue_doctor')), 
          ),
        ],
        child: const WaitingScreenPage(),
      ),
    );
  }
}