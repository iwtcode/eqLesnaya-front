import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/daily_report_row_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../domain/entities/ticket_entity.dart';
import '../datasources/ticket_data_source.dart';
import '../../core/utils/ticket_category.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DailyReportRowEntity>>> getDailyReport() async {
    try {
      final report = await remoteDataSource.getDailyReport();
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Непредвиденная ошибка при получении отчета'));
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> callNextTicket(int windowNumber, String? categoryPrefix) async {
    try {
      final ticket = await remoteDataSource.callNextTicket(windowNumber, categoryPrefix);
      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Произошла непредвиденная ошибка'));
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> callSpecificTicket(String ticketId, int windowNumber) async {
    try {
      final ticket = await remoteDataSource.callSpecificTicket(ticketId, windowNumber);
      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Непредвиденная ошибка при вызове талона'));
    }
  }

  @override
  Future<Either<Failure, void>> registerCurrentTicket(String ticketId) async {
    try {
      await remoteDataSource.updateTicketStatus(ticketId, 'зарегистрирован');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> completeCurrentTicket(String ticketId) async {
    try {
      await remoteDataSource.updateTicketStatus(ticketId, 'завершен');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TicketEntity?>> getCurrentTicket(int windowNumber) async {
    try {
      final ticket = await remoteDataSource.getCurrentTicket(windowNumber);
      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TicketEntity>>> getTicketsByCategory(
      TicketCategory category) async {
    try {
      final tickets = await remoteDataSource.getTicketsByCategory(category);
      return Right(tickets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<TicketEntity>>> getTickets() async {
    try {
      final tickets = await remoteDataSource.getTickets();
      return Right(tickets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}