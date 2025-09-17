import '../../domain/entities/waiting_screen_entity.dart';
import '../../domain/repositories/waiting_screen_repository.dart';
import '../../domain/usecases/get_waiting_screen_data.dart';
import '../datasources/waiting_screen_remote_data_source.dart';

class WaitingScreenRepositoryImpl implements WaitingScreenRepository {
  final WaitingScreenRemoteDataSource remoteDataSource;

  WaitingScreenRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<DoctorQueueTicketEntity>> getWaitingScreenData(
    GetWaitingScreenDataParams params,
  ) {
    return remoteDataSource.getQueueUpdates();
  }

  @override
  Future<List<int>> getActiveCabinets() {
    return remoteDataSource.getActiveCabinets();
  }
}
