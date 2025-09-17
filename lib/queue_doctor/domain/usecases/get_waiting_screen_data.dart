import 'package:equatable/equatable.dart';
import '../../core/usecases/usecase.dart';
import '../entities/waiting_screen_entity.dart';
import '../repositories/waiting_screen_repository.dart';

// --- ИСПРАВЛЕНИЕ: UseCase теперь работает со списком талонов ---
class GetWaitingScreenData
    implements
        UseCase<List<DoctorQueueTicketEntity>, GetWaitingScreenDataParams> {
  final WaitingScreenRepository repository;

  GetWaitingScreenData(this.repository);

  @override
  Stream<List<DoctorQueueTicketEntity>> call(
    GetWaitingScreenDataParams params,
  ) {
    return repository.getWaitingScreenData(params);
  }
}

class GetWaitingScreenDataParams extends Equatable {
  const GetWaitingScreenDataParams();

  @override
  List<Object?> get props => [];
}
