import 'package:flutter/material.dart';
import 'chatbot/chat_input.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  // Número de mensajes de contexto que se guardarán
  final int _messageHistoryLimit = 3;

  // Lista de mensajes actuales
  List<Map<String, dynamic>> _messages = [];

  // Lista para almacenar el historial de mensajes que será enviado a la API
  List<Map<String, String>> _chatHistory = [];

  // Instancia de FlutterTts
  final FlutterTts _flutterTts = FlutterTts();

  // Estado para indicar si se está obteniendo una respuesta
  bool _isFetchingResponse = false;

  @override
  void initState() {
    super.initState();

    // Solicitar permisos
    _requestPermissions();

    // Configurar FlutterTts
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US"); // Configurado en inglés
    await _flutterTts.setPitch(1.2); // Ajusta el tono
    await _flutterTts.setSpeechRate(0.5); // Ajusta la velocidad
    await _flutterTts.setVolume(1.0); // Asegura que el volumen esté al máximo
    await _flutterTts.awaitSpeakCompletion(true); // Espera a que termine de hablar
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.speech.request();
  }

  Future<void> _sendMessage({String? voiceText}) async {
    final text = voiceText ?? _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _isFetchingResponse = true;
      _messages.add({'text': text, 'isUser': true});
      _chatHistory.add({'role': 'user', 'content': text});
    });

    // Limitar el historial a los últimos mensajes, multiplicado por 2 para usuario y asistente
    if (_chatHistory.length > _messageHistoryLimit * 2) {
      _chatHistory.removeRange(0, _chatHistory.length - _messageHistoryLimit * 2);
    }

    if (voiceText == null) {
      _controller.clear();
    }

    // Llama a la API para obtener la respuesta de ChatGPT
    final response = await _getChatGPTResponse();

    setState(() {
      _messages.add({'text': response, 'isUser': false});
      _chatHistory.add({'role': 'assistant', 'content': response});
      _isFetchingResponse = false;
    });

    await _speak(response);
  }

  Future<String> _getChatGPTResponse() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return 'Error: La clave API no está configurada.';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Construye el cuerpo de la solicitud con el historial completo
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': _chatHistory,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error al conectar con la API de OpenAI: $e';
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Función intermedia para manejar el input de voz
  void _handleVoiceInput(String voiceText) {
    _sendMessage(voiceText: voiceText);
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Área de historial de conversación
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final messageBackground = message['isUser']
                        ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[300]
                        : Colors.blue[100]
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300];

                    return ListTile(
                      title: Align(
                        alignment: message['isUser']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: messageBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(message['text']),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Campo de texto y botón de enviar
              ChatInput(
                controller: _controller,
                onSend: () => _sendMessage(),
                onVoiceInput: _handleVoiceInput, // Usa la función intermedia
              ),
            ],
          ),
          // Superposición para indicar que se está esperando una respuesta
          if (_isFetchingResponse)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitCircle(
                      color: Colors.white,
                      size: 50.0,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Obteniendo respuesta...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}



