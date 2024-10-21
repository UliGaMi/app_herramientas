import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechTextScreen extends StatefulWidget {
  static const routeName = '/speech_text';

  @override
  _SpeechTextScreenState createState() => _SpeechTextScreenState();
}

class _SpeechTextScreenState extends State<SpeechTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Presiona el botón y empieza a hablar...';
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Función para iniciar el reconocimiento de voz en español
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'es_ES',  // Cambia el idioma a español (España)
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Función para leer el texto en voz alta en español
  Future<void> _speak() async {
    await _flutterTts.setLanguage('es-ES');  // Configurar la voz en español
    await _flutterTts.speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictado y Lectura de Texto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área de texto que muestra lo dictado
            TextField(
              maxLines: 6,
              controller: TextEditingController(text: _text),
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Texto dictado',
              ),
            ),
            const SizedBox(height: 20),
            // Botón para empezar a dictar
            ElevatedButton.icon(
              onPressed: _listen,
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Detener Dictado' : 'Empezar a Dictar'),
            ),
            const SizedBox(height: 20),
            // Botón para que lea el texto en voz alta
            ElevatedButton.icon(
              onPressed: _speak,
              icon: Icon(Icons.volume_up),
              label: Text('Leer en Voz Alta'),
            ),
          ],
        ),
      ),
    );
  }
}


