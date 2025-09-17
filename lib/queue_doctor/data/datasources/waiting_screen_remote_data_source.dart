import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../models/waiting_screen_model.dart';

abstract class WaitingScreenRemoteDataSource {
  Stream<List<DoctorQueueTicketModel>> getQueueUpdates();
  Future<List<int>> getActiveCabinets();
}

class WaitingScreenRemoteDataSourceImpl
    implements WaitingScreenRemoteDataSource {
  final http.Client _client;
  bool _isInitialFetchDone = false;
  final Map<String, DoctorQueueTicketModel> _tickets = {};

  WaitingScreenRemoteDataSourceImpl({http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<List<int>> getActiveCabinets() async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/api/doctor/cabinets/active'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.cast<int>().toList();
    } else {
      throw Exception(
        'Не удалось загрузить список кабинетов: ${response.statusCode}',
      );
    }
  }

  @override
  Stream<List<DoctorQueueTicketModel>> getQueueUpdates() {
    final controller = StreamController<List<DoctorQueueTicketModel>>();

    Future<void> fetchAllQueues() async {
      try {
        final response = await _client.get(
          Uri.parse('${AppConfig.apiBaseUrl}/api/doctor/queue-all'),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(
            utf8.decode(response.bodyBytes),
          );
          _tickets.clear();
          for (var item in data) {
            final ticket = DoctorQueueTicketModel.fromJson(item);
            _tickets[ticket.ticketNumber] = ticket;
          }
          if (!controller.isClosed) {
            controller.add(_tickets.values.toList());
          }
        } else {
          throw Exception(
            'Failed to load initial queue data: ${response.statusCode}',
          );
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    void connectSse() async {
      if (!_isInitialFetchDone) {
        await fetchAllQueues();
        _isInitialFetchDone = true;
      }

      try {
        final request = http.Request(
          'GET',
          Uri.parse('${AppConfig.apiBaseUrl}/tickets'),
        );
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Cache-Control'] = 'no-cache';

        final response = await _client.send(request);

        if (response.statusCode == 200) {
          response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen(
                (line) {
                  if (line.startsWith('data:')) {
                    fetchAllQueues();
                  }
                },
                onDone: () =>
                    Future.delayed(const Duration(seconds: 5), connectSse),
                onError: (e, s) {
                  controller.addError(e, s);
                  Future.delayed(const Duration(seconds: 5), connectSse);
                },
              );
        } else {
          controller.addError(
            Exception('SSE connection failed: ${response.statusCode}'),
          );
          Future.delayed(const Duration(seconds: 5), connectSse);
        }
      } catch (e) {
        controller.addError(e);
        Future.delayed(const Duration(seconds: 5), connectSse);
      }
    }

    connectSse();
    return controller.stream;
  }
}
