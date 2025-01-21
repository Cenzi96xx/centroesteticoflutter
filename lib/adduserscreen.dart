import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('https://centro-dnz3.onrender.com/utenti');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nome': _nomeController.text,
        'cognome': _cognomeController.text,
        'telefono': _telefonoController.text,
        'password': _passwordController.text,
        'is_admin': _isAdmin ? 1 : 0,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utente registrato con successo!')),
      );
      Navigator.pop(context); // Torna alla homepage
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nella registrazione dell’utente: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registra Nuovo Utente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci il nome' : null,
              ),
              TextFormField(
                controller: _cognomeController,
                decoration: InputDecoration(labelText: 'Cognome'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci il cognome' : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Inserisci il telefono' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Inserisci una password valida (min. 6 caratteri)' : null,
              ),
              SwitchListTile(
                title: Text('Amministratore'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Registra Utente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
