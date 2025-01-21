import 'package:flutter/material.dart';
import 'adduserscreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final isAdmin = args['isAdmin'];
    final userId = args['userId'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Benvenuto ${isAdmin ? "Amministratore" : "Utente"}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Questo bottone deve essere visibile solo se l'utente NON è un amministratore
            if (!isAdmin)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddUserScreen(),
                    ),
                  );
                },
                child: Text('Registra Nuovo Utente'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/schedule_appointment',
                  arguments: {'isAdmin': isAdmin, 'userId': userId},
                );
              },
              child: Text('Fissa un Appuntamento'),
            ),
            // Bottone visibile solo per gli utenti (non amministratori)
            if (!isAdmin)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/myAppointments',
                    arguments: {'userId': userId},
                  );
                },
                child: Text('I miei Appuntamenti'),
              ),
            // Bottone visibile solo per gli amministratori
            if (isAdmin)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/manageAppointments',
                    arguments: {'isAdmin': isAdmin},
                  );
                },
                child: Text('Gestisci Appuntamenti'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
