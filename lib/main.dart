import 'package:centro/adduserscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'appointment_screen.dart';
import 'login.dart';
import 'home.dart';
import 'calendar_screen.dart';
import 'manage_appointments.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centro Estetico',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('it'), // Italiano
      ],
      locale: Locale('it'),  // Imposta l'italiano come lingua predefinita
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/adduserscreen': (context) => AddUserScreen(),
        // Rimuoviamo la navigazione diretta a ManageAppointmentsScreen qui
      },
      onGenerateRoute: (settings) {
        // Gestisce la route per l'appuntamento
        if (settings.name == '/appointment') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AppointmentScreen(
              selectedDate: args['selectedDate'] ?? DateTime.now(),
              isAdmin: args['isAdmin'] ?? false,
              userId: args['userId'] ?? 1,
            ),
          );
        }
        // Gestisce la route per il calendario
        if (settings.name == '/schedule_appointment') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CalendarScreen(
              isAdmin: args['isAdmin'],
              userId: args['userId'],
            ),
          );
        }
        // Gestisce la route per la gestione degli appuntamenti

      },
    );
  }
}
