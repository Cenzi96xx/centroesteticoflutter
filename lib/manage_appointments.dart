import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageAppointmentsScreen extends StatefulWidget {
  final bool isAdmin;

  const ManageAppointmentsScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _ManageAppointmentsScreenState createState() => _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  late List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _fetchAppointments();
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Funzione per ottenere gli appuntamenti in attesa
  Future<void> _fetchAppointments() async {
    try {
      final response = await http.get(Uri.parse('https://centro-dnz3.onrender.com/appuntamenti?stato=in+attesa'));
      if (response.statusCode == 200) {
        final List appointments = json.decode(response.body);
        setState(() {
          _appointments = appointments.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Errore nel recupero degli appuntamenti');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel recupero degli appuntamenti: $e')),
      );
    }
  }

  // Funzione per aggiornare lo stato dell'appuntamento
  Future<void> _updateAppointmentStatus(int appointmentId, String status, int userId) async {
    try {
      final response = await http.put(
        Uri.parse('https://centro-dnz3.onrender.com/appuntamenti/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'stato': status, 'userId': userId.toString()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Rimuove l'appuntamento dalla lista
          _appointments.removeWhere((appointment) => appointment['id'] == appointmentId);
        });

        // Mostra una notifica di successo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appuntamento $status con successo'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Mostra una notifica di errore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nell\'aggiornare lo stato dell\'appuntamento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Gestione degli errori
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestisci Appuntamenti')),
      body: _appointments.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          final date = DateTime.parse(appointment['data_inizio']);
          final formattedDate = '${date.day}/${date.month} ${date.hour}:${date.minute}';

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ExpansionTile(
              title: Text('Appuntamento $formattedDate'),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        _updateAppointmentStatus(
                            appointment['id_appuntamento'], 'accettato', appointment['id_utente']);
                      },
                      child: Text('Accetta'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        _updateAppointmentStatus(
                            appointment['id_appuntamento'], 'rifiutato', appointment['id_utente']);
                      },
                      child: Text('Rifiuta'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
