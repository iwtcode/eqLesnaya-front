import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/waiting_screen_repository.dart';
import '../../domain/usecases/get_waiting_screen_data.dart';
import 'waiting_screen_event.dart';
import 'waiting_screen_state.dart';
import '../../domain/entities/waiting_screen_entity.dart';

class WaitingScreenBloc extends Bloc<WaitingScreenEvent, WaitingScreenState> {
  final GetWaitingScreenData _getWaitingScreenData;
  // --- ИСПРАВЛЕНИЕ: Поле repository было неиспользуемым и удалено для чистоты кода ---
  // final WaitingScreenRepository _repository;

  WaitingScreenBloc({
    required GetWaitingScreenData getWaitingScreenData,
    required WaitingScreenRepository repository, // Параметр оставлен для DI
  }) : _getWaitingScreenData = getWaitingScreenData,
       // _repository = repository, // Инициализация убрана
       super(WaitingScreenInitial()) {
    on<SubscribeToQueueUpdates>(_onSubscribeToQueueUpdates);
  }

  Future<void> _onSubscribeToQueueUpdates(
    SubscribeToQueueUpdates event,
    Emitter<WaitingScreenState> emit,
  ) async {
    emit(WaitingScreenLoading());

    await emit.forEach<List<DoctorQueueTicketEntity>>(
      _getWaitingScreenData(const GetWaitingScreenDataParams()),
      onData: (tickets) {
        return DoctorQueueLoaded(tickets: tickets);
      },
      onError: (error, stackTrace) =>
          WaitingScreenError(message: error.toString()),
    );
  }
}
