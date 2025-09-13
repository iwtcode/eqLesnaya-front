import 'package:elqueue/queue_reception/data/datasources/ad_display_remote_datasource.dart';
import 'package:elqueue/queue_reception/data/repositories/ad_display_repository_impl.dart';
import 'package:elqueue/queue_reception/domain/repositories/ad_display_repository.dart';
import 'package:elqueue/queue_reception/presentation/blocs/ad_display_bloc.dart';
import 'package:elqueue/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:elqueue/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:elqueue/schedule/domain/usecases/get_today_schedule.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// --- ИЗМЕНЕНИЕ: ДОБАВЛЕНЫ ИМПОРТЫ ---
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player_web/video_player_web.dart';
// ------------------------------------

import 'presentation/blocs/schedule_bloc.dart';
import 'presentation/pages/schedule_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- ИЗМЕНЕНИЕ: ИСПРАВЛЕНА РЕГИСТРАЦИЯ ПЛАГИНА ---
  // Явная регистрация веб-реализации плагина video_player
  if (kIsWeb) {
    VideoPlayerPlugin();
  }
  // ---------------------------------------------
  
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ru');

  final httpClient = http.Client();

  final scheduleRemoteDataSource =
      ScheduleRemoteDataSourceImpl(client: httpClient);
  final scheduleRepository =
      ScheduleRepositoryImpl(remoteDataSource: scheduleRemoteDataSource);
  final getTodaySchedule = GetTodaySchedule(scheduleRepository);

  final adDisplayRepository = AdDisplayRepositoryImpl(
    dataSource: AdDisplayRemoteDataSource(client: httpClient),
  );

  runApp(MyApp(
    getTodaySchedule: getTodaySchedule,
    adDisplayRepository: adDisplayRepository,
  ));
}

class MyApp extends StatelessWidget {
  final GetTodaySchedule getTodaySchedule;
  final AdDisplayRepository adDisplayRepository;

  const MyApp({
    super.key,
    required this.getTodaySchedule,
    required this.adDisplayRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleBloc>(
          create: (context) =>
              ScheduleBloc(getTodaySchedule: getTodaySchedule),
        ),
        BlocProvider<AdDisplayBloc>(
          create: (context) => AdDisplayBloc(repository: adDisplayRepository)
            // ИЗМЕНЕНО: Передаем тип экрана при инициализации
            ..add(const FetchEnabledAds(screen: 'schedule')),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Расписание врачей',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Manrope',
        ),
        home: const SchedulePage(),
      ),
    );
  }
}