import '../entities/waiting_screen_entity.dart';
import '../usecases/get_waiting_screen_data.dart';

abstract class WaitingScreenRepository {
  // --- ИСПРАВЛЕНИЕ: Метод теперь возвращает Stream со списком талонов ---
  Stream<List<DoctorQueueTicketEntity>> getWaitingScreenData(
    GetWaitingScreenDataParams params,
  );

  Future<List<int>> getActiveCabinets();
}
