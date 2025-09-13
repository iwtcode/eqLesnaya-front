import 'package:elqueue/terminal/presentation/screens/phone_input_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/selection_button.dart';
import 'confirmation_screen.dart';
import '../../data/api/ticket_api.dart';
import '../../domain/entities/service_entity.dart';

/// Экран выбора услуги.
class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  late final Future<List<ServiceEntity>> _servicesFuture;
  final TicketApi _api = TicketApi();

  @override
  void initState() {
    super.initState();
    _servicesFuture = _api.fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Выберите услугу',
            style: TextStyle(
                fontSize: screenWidth * 0.06, fontWeight: FontWeight.normal),
          ),
        ),
        centerTitle: true,
        toolbarHeight: screenHeight * 0.15,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: 30.0),
          child: FutureBuilder<List<ServiceEntity>>(
            future: _servicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Ошибка: \n${snapshot.error}',
                    style: const TextStyle(color: Colors.red));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Нет доступных услуг');
              }
              final services = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final service in services)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SimpleButton(
                          text: service.title,
                          onPressed: () {
                            if (service.id == 'confirm_appointment') {
                              _navigateToPhoneInput(context, service);
                            } else {
                              _navigateToConfirmation(context, service);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToPhoneInput(BuildContext context, ServiceEntity service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneInputScreen(service: service),
      ),
    );
  }

  Future<void> _navigateToConfirmation(
      BuildContext context, ServiceEntity service) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );
    try {
      final resp = await _api.selectService(service.id);
      final serviceName = resp['service_name'] ?? service.title;
      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
              serviceName: serviceName, serviceId: service.id),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}