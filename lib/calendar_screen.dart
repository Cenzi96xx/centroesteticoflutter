import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'appointment_screen.dart'; // Importa la schermata di appuntamento
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final bool isAdmin;
  final int userId;

  const CalendarScreen({required this.isAdmin, required this.userId});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late List<Appointment> _appointments = [];
  Map<int, Map<String, String>> _userMap = {};

  // Variabile per salvare l'ID dell'appuntamento selezionato
  int? _selectedAppointmentId;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _fetchUsers().then((_) => _fetchAppointments());
    } else {
      _fetchAppointments();
    }
  }

  // Funzione per recuperare gli utenti
  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('https://centro-dnz3.onrender.com/utenti'));
    if (response.statusCode == 200) {
      final List users = json.decode(response.body);
      setState(() {
        _userMap = {
          for (var user in users)
            user['id']: {
              'nome': user['nome'],
              'cognome': user['cognome'],
            }
        };
      });
    } else {
      throw Exception('Errore nel recupero degli utenti');
    }
  }

  // Funzione per recuperare gli appuntamenti
  Future<void> _fetchAppointments() async {
    final url = widget.isAdmin
        ? 'https://centro-dnz3.onrender.com/appuntamenti'
        : 'https://centro-dnz3.onrender.com/appuntamenti?userId=${widget.userId}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List appointments = json.decode(response.body);
      setState(() {
        _appointments = appointments.map((e) {
          final appointment = e as Map<String, dynamic>;
          DateTime startTime = DateTime.parse(appointment['data_inizio']);
          DateTime endTime = DateTime.parse(appointment['data_fine']);
          int userId = appointment['id_utente'];
          int id= appointment['id_appuntamento'];
          // Imposta il soggetto in base al ruolo e all'appartenenza dell'appuntamento
          String subject;
          Color color;

          if (widget.isAdmin) {
            subject = 'Appuntamento con ${_userMap[userId]?['nome'] ?? 'N/A'} ${_userMap[userId]?['cognome'] ?? ''}';
            color = Colors.red;
          } else {
            if (userId == widget.userId) {
              subject = 'Il tuo appuntamento';
              color = Colors.green; // Colore verde per appuntamenti dell'utente
            } else {
              subject = 'Occupato';
              color = Colors.red; // Colore rosso per appuntamenti altrui
            }
          }

          return Appointment(
            id: id,
            startTime: startTime,
            endTime: endTime,
            subject: subject,
            color: color,
            notes: appointment['note'], // Le note sono ora visibili
          );
        }).toList();
      });
    } else {
      throw Exception('Errore nel recupero degli appuntamenti');
    }
  }

  // Funzione per mostrare i dettagli dell'appuntamento
  void _showAppointmentDetails(Appointment appointment) {
    String formattedDate = DateFormat('EEE dd MMM HH:mm', 'it_IT').format(appointment.startTime);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dettagli Appuntamento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Utente: ${appointment.subject}'),
                Text('Inizio: $formattedDate'),
                if (appointment.notes != null && appointment.notes!.isNotEmpty)
                  Text('Note: ${appointment.notes}'),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Chiudi'),
                  ),
                ),
                // Aggiungi il pulsante per eliminare se l'utente è un amministratore
                if (widget.isAdmin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Chiama la funzione per eliminare l'appuntamento
                        await _deleteAppointment();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Elimina Appuntamento'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Funzione per eliminare l'appuntamento
  Future<void> _deleteAppointment() async {
    if (_selectedAppointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nessun appuntamento selezionato!')),
      );
      return;
    }

    try {
      // Fai la richiesta DELETE all'API
      final response = await http.delete(
        Uri.parse('https://centro-cspd.onrender.com/appuntamenti/$_selectedAppointmentId'),
      );

      // Verifica la risposta
      if (response.statusCode == 200) {
        setState(() {
          _appointments.removeWhere((appt) => appt.id == _selectedAppointmentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appuntamento eliminato con successo!')),
        );
        Navigator.pop(context);  // Chiudi la schermata dei dettagli
      } else {
        // Log della risposta dettagliata per il debug
        print('Errore nella risposta: ${response.statusCode}');
        print('Messaggio di errore: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'eliminazione dell\'appuntamento: ${response.body}')),
        );
      }
    } catch (e) {
      // Gestisci eventuali eccezioni durante la richiesta
      print('Eccezione durante la richiesta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante la connessione al server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendario Appuntamenti')),
      body: SfCalendar(
        view: CalendarView.week,
        initialDisplayDate: _selectedDate,
        headerStyle: CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        firstDayOfWeek: 1,
        timeSlotViewSettings: TimeSlotViewSettings(
          timeFormat: 'HH:mm',
          startHour: 8,
          endHour: 19,
          timeInterval: Duration(minutes: 25),
        ),
        onTap: (details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            final appointment = details.appointments!.first;

            // Salva l'ID dell'appuntamento selezionato
            _selectedAppointmentId = appointment.id;

            if (widget.isAdmin || appointment.subject == 'Il tuo appuntamento') {
              _showAppointmentDetails(appointment);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Questa fascia oraria è già occupata!')),
              );
            }
          } else if (details.targetElement == CalendarElement.calendarCell) {
            setState(() {
              _selectedDate = details.date!;
            });

            if (!widget.isAdmin || !_isTimeSlotOccupied(_selectedDate, _selectedDate.add(Duration(minutes: 30)))) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentScreen(
                    selectedDate: _selectedDate,
                    isAdmin: widget.isAdmin,
                    userId: widget.userId,
                  ),
                ),
              );
            }
          }
        },
        dataSource: AppointmentDataSource(_appointments),
      ),
    );
  }

  bool _isTimeSlotOccupied(DateTime startTime, DateTime endTime) {
    for (var appointment in _appointments) {
      if ((startTime.isBefore(appointment.endTime) && startTime.isAfter(appointment.startTime)) ||
          (endTime.isBefore(appointment.endTime) && endTime.isAfter(appointment.startTime)) ||
          (startTime.isBefore(appointment.startTime) && endTime.isAfter(appointment.endTime))) {
        return true;
      }
    }
    return false;
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
