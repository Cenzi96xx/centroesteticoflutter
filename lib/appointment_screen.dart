import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentScreen extends StatefulWidget {
  final DateTime selectedDate;
  final bool isAdmin;
  final int userId;

  const AppointmentScreen({
    Key? key,
    required this.selectedDate,
    required this.isAdmin,
    required this.userId,
  }) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late TextEditingController _startTimeController;
  late List<Map<String, dynamic>> _users = [];
  late List<Map<String, dynamic>> _services = [];
  late int _selectedUserId;
  late List<int> _selectedServices;

  @override
  void initState() {
    super.initState();
    _startTimeController = TextEditingController(
        text: widget.selectedDate.toLocal().toString());

    // Imposta un valore di default per l'ID dell'utente
    _selectedUserId = widget.userId != null ? widget.userId : -1; // Usa un valore di default
    _selectedServices = [];

    if (widget.isAdmin) {
      _fetchUsers();
    }
    _fetchServices();
  }

  // Funzione per ottenere la lista degli utenti
  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('https://centro-dnz3.onrender.com/utenti'));
    if (response.statusCode == 200) {
      final List users = json.decode(response.body);
      setState(() {
        _users = users.map((e) => e as Map<String, dynamic>).toList();
      });
    } else {
      throw Exception('Errore nel recupero degli utenti');
    }
  }

  // Funzione per ottenere la lista dei servizi
  Future<void> _fetchServices() async {
    final response = await http.get(Uri.parse('https://centro-dnz3.onrender.com/servizi'));
    if (response.statusCode == 200) {
      final List services = json.decode(response.body);
      setState(() {
        _services = services.map((e) => e as Map<String, dynamic>).toList();
      });
    } else {
      throw Exception('Errore nel recupero dei servizi');
    }
  }

  // Funzione per inviare i dati dell'appuntamento
  Future<void> _submitAppointment() async {
    final url = Uri.parse('https://centro-dnz3.onrender.com/appuntamenti');
    final response = await http.post(url, body: json.encode({
      'id_utente': widget.isAdmin ? _selectedUserId : widget.userId,
      'is_admin': widget.isAdmin,
      'data_inizio': widget.selectedDate.toIso8601String(),
      'stato': widget.isAdmin ? 'accettato' : 'in attesa',
      'id_servizi': _selectedServices,
    }), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appuntamento prenotato con successo!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nella prenotazione dell\'appuntamento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prenota Appuntamento'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16.0), // Aggiunge spazio minimo in basso
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data selezionata: ${widget.selectedDate.toLocal()}'),
              SizedBox(height: 16),
              widget.isAdmin
                  ? DropdownButton<int>(
                value: _selectedUserId,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedUserId = newValue!;
                  });
                },
                items: _users.map<DropdownMenuItem<int>>((user) {
                  return DropdownMenuItem<int>(
                    value: user['id'],
                    child: Text('${user['nome']} ${user['cognome']}'),
                  );
                }).toList(),
              )
                  : Container(),
              SizedBox(height: 16),
              Text(
                'Seleziona Servizi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: _services.map((service) {
                    return CheckboxListTile(
                      title: Text(service['nome']),
                      value: _selectedServices.contains(service['id']),
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            _selectedServices.add(service['id']);
                          } else {
                            _selectedServices.remove(service['id']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _submitAppointment,
                  child: Text('Prenota Appuntamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
