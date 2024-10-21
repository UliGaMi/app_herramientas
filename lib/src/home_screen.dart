// lib/src/home_screen.dart
import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'qr_scanner_screen.dart';
import 'sensor_screen.dart';
import 'speech_text_screen.dart';  // Importa la nueva vista
import 'package:url_launcher/url_launcher.dart';  // Importa la librería para abrir enlaces

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas para el BottomNavigationBar
  static List<Widget> _screens = [
    StudentInfoScreen(),  // Página de información del alumno
    SpeechTextScreen(),  // Nueva vista de dictado y lectura de texto
    GPSScreen(),
    QRScannerScreen(),
    SensorScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App del Estudiante'),
      ),
      body: _screens[_selectedIndex],  // Mostrar la pantalla según el índice seleccionado
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Alumno',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Dictado',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'GPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensores',
          ),
        ],
        currentIndex: _selectedIndex,  // Índice seleccionado actualmente
        selectedItemColor: Colors.blue,  // Color para el ítem seleccionado (azul)
        unselectedItemColor: Colors.grey,  // Color para los ítems no seleccionados (gris)
        onTap: _onItemTapped,  // Cambiar de pantalla al seleccionar un ítem
      ),
    );
  }
}

// Widget que muestra la información del alumno
class StudentInfoScreen extends StatelessWidget {
  const StudentInfoScreen({super.key});

  final String universityLogo = 'assets/logo.png';
  final String degree = 'Ingeniería en Software';
  final String subject = 'Programación para Móviles';
  final String group = '9B';
  final String studentName = 'Ulises Galvez Miranda';
  final String studentId = '213691';
  final String repositoryLink = 'https://github.com/UliGaMi';

  // Función para abrir el enlace al repositorio
  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://github.com/UliGaMi');
    if (!await launchUrl(url)) {
      throw 'No se puede abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Logo de la universidad
          CircleAvatar(
            radius: 80,
            backgroundImage: AssetImage(universityLogo),
          ),
          const SizedBox(height: 16),
          // Datos del estudiante
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(studentName),
              subtitle: Text('Matrícula: $studentId'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.school),
              title: Text(degree),
              subtitle: Text('Grupo: $group'),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text(subject),
            ),
          ),
          const SizedBox(height: 16),
          // Botón para ver el repositorio
          ElevatedButton(
            onPressed: _launchURL,  // Llama a la función que abre el enlace
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Ir al repositorio',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}









