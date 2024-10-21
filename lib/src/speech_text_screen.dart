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
  String _text = 'Press the button and start speaking...';
  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Función para iniciar el reconocimiento de voz en inglés
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
        setState(() {
          _isListening = true;
          _text = '';  // Limpiar el texto antes de empezar a dictar
        });
        _speech.listen(
          localeId: 'en_US',  // Cambia el idioma a inglés (EE.UU.)
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

  // Función para leer el texto en voz alta en inglés
  Future<void> _speak() async {
    await _flutterTts.setLanguage('en-US');  // Configurar la voz en inglés (EE.UU.)
    await _flutterTts.speak(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text and Text to Speech'),
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
                labelText: 'Recognized Text',
              ),
            ),
            const SizedBox(height: 20),
            // Botón para empezar a dictar
            ElevatedButton.icon(
              onPressed: _listen,
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
            const SizedBox(height: 20),
            // Botón para que lea el texto en voz alta
            ElevatedButton.icon(
              onPressed: _speak,
              icon: Icon(Icons.volume_up),
              label: Text('Read Aloud'),
            ),
          ],
        ),
      ),
    );
  }
}



