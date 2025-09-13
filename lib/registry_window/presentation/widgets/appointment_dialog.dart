import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/doctor_entity.dart';
import '../blocs/appointment/appointment_bloc.dart';

class AppointmentDialog extends StatefulWidget {
  final String ticketId;

  const AppointmentDialog({super.key, required this.ticketId});

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  int? _selectedSlotId;
  final TextEditingController _patientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AppointmentBloc>();
    if (bloc.state.selectedPatient != null) {
      bloc.add(LoadPatientAppointments(bloc.state.selectedPatient!.id));
    }
  }

  @override
  void dispose() {
    _patientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listenWhen: (prev, current) =>
          prev.selectedPatient != current.selectedPatient ||
          prev.error != current.error ||
          prev.submissionSuccess != current.submissionSuccess,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
        if (state.submissionSuccess) {
          Navigator.of(context).pop(true);
        }
        if (state.selectedPatient != null && _patientController.text != state.selectedPatient!.fullName) {
          _patientController.text = state.selectedPatient!.fullName;
        } else if (state.selectedPatient == null) {
          _patientController.clear();
        }
        if (state.selectedPatient != null) {
          context.read<AppointmentBloc>().add(LoadPatientAppointments(state.selectedPatient!.id));
        }
      },
      builder: (context, state) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF1F3F4),
          title: const Text('Запись к врачу на сегодня'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.75,
            child: _buildForm(context, state),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4EB8A6), foregroundColor: Colors.white),
              onPressed: (_selectedSlotId != null && !state.isLoading)
                  ? () {
                      context.read<AppointmentBloc>().add(SubmitAppointment(
                            scheduleId: _selectedSlotId!,
                            ticketId: int.parse(widget.ticketId),
                          ));
                    }
                  : null,
              child: const Text('Создать запись'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, AppointmentState state) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildSpecialtySelector(context, state)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildDoctorSelector(context, state)),
          ],
        ),
        const Divider(height: 32),
        Expanded(child: _buildScheduler(context, state)),
      ],
    );
  }

  Widget _buildSpecialtySelector(BuildContext context, AppointmentState state) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Специализация', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
      value: state.selectedSpecialization ?? 'Все специальности',
      isExpanded: true,
      items: state.specializations.map((specialty) {
        return DropdownMenuItem<String>(
          value: specialty,
          child: Text(specialty, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (specialty) {
        context.read<AppointmentBloc>().add(AppointmentSpecializationSelected(specialty));
        setState(() { _selectedSlotId = null; });
      },
    );
  }

   Widget _buildDoctorSelector(BuildContext context, AppointmentState state) {
    return DropdownButtonFormField<DoctorEntity?>(
      dropdownColor: Colors.white,
      decoration: const InputDecoration(labelText: 'Врач', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
      value: state.selectedDoctor,
      isExpanded: true,
      items: [
        const DropdownMenuItem<DoctorEntity?>(
          value: null,
          child: Text('Не выбрано', style: TextStyle(color: Colors.grey)),
        ),
        ...state.filteredDoctors.map((doctor) {
          return DropdownMenuItem<DoctorEntity>(
            value: doctor,
            child: Tooltip(
              message: doctor.fullName,
              child: Text(
                doctor.fullName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ],
      onChanged: (doctor) {
        context.read<AppointmentBloc>().add(AppointmentDoctorSelected(doctor));
        setState(() { _selectedSlotId = null; });
      },
    );
  }

  Widget _buildScheduler(BuildContext context, AppointmentState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.selectedDoctor == null) {
      return const Center(child: Text('Выберите врача для отображения расписания.'));
    }
    if (state.schedule.isEmpty) {
      return const Center(child: Text('Нет доступных слотов на выбранную дату.'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3,
      ),
      itemCount: state.schedule.length,
      itemBuilder: (context, index) {
        final slot = state.schedule[index];
        final isSelected = slot.id == _selectedSlotId;

        return Tooltip(
          message: slot.isAvailable ? "Свободно" : "Занято: ${slot.patientName ?? 'н/д'}",
          child: ChoiceChip(
            label: Text(DateFormat('HH:mm').format(slot.startTime)),
            selected: isSelected,
            selectedColor: const Color(0xFF415BE7),
            labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black),
            backgroundColor: slot.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
            onSelected: slot.isAvailable
                ? (selected) {
                    setState(() { _selectedSlotId = selected ? slot.id : null; });
                  }
                : null,
          ),
        );
      },
    );
  }
}