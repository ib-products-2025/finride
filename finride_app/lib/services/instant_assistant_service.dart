import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:audio_recorder/audio_recorder.dart';

/// A service class to manage real-time audio recording, transcription, and
/// post-processing (summary, compliance extraction) via OpenAI Whisper API.
class InstantAssistantService extends ChangeNotifier {
  // The actual API key, as requested.
  final String openAiApiKey =
      "";

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  StreamSubscription<List<int>>? _audioSub;
  final List<int> _audioBuffer = [];

  String _liveTranscript = '';
  String get liveTranscript => _liveTranscript;

  String _interactionSummary = '';
  String get interactionSummary => _interactionSummary;

  String _complianceDetails = '';
  String get complianceDetails => _complianceDetails;

  /// Starts the audio capture and records data into _audioBuffer, to be sent to
  /// the OpenAI Whisper API upon completion. This sample uses actual microphone data capture.
  Future<void> startRecordingAssistant() async {
    if (_isRecording) return; // Prevent multiple recordings
    _isRecording = true;
    notifyListeners();

    // Request microphone permission
    if (await Permission.microphone.request().isGranted) {
      // Start capturing audio from the microphone
      _audioSub = _captureAudioFromMicrophone().listen((chunk) {
        _audioBuffer.addAll(chunk);
        // Optionally, perform live partial transcription
        // if you have a streaming approach.
        _liveTranscript = "[Recording audio ...]";
        notifyListeners();
      });
    } else {
      // Handle microphone permission denied scenario
      _isRecording = false;
      notifyListeners();
      debugPrint('Microphone permission denied.');
    }
  }

  /// Stops audio capture, calls OpenAI Whisper to transcribe the entire buffer,
  /// then extracts summary and compliance details from the transcript (using GPT).
  Future<void> stopRecordingAssistant() async {
    if (!_isRecording) return;
    _isRecording = false;
    notifyListeners();

    // Cancel the subscription and finalize the audio buffer.
    await _audioSub?.cancel();
    _audioSub = null;

    try {
      // STEP 1: Send audio to OpenAI Whisper for transcription
      final transcription = await _transcribeAudioWithOpenAI(_audioBuffer);
      _liveTranscript = transcription;

      // STEP 2: Generate summary and compliance details from the transcribed text.
      // This step calls GPT or any text processing endpoint from OpenAI.
      _interactionSummary = await _chatGptProcess(
        transcription,
        "Provide a concise summary of the user's conversation:"
      );
      _complianceDetails = await _chatGptProcess(
        transcription,
        "Extract any compliance-related issues or statements from the conversation:"
      );

      // Clear audio buffer
      _audioBuffer.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('stopRecordingAssistant error: $e');
      _audioBuffer.clear();
    }
  }

  /// Example: sends a POST request to the OpenAI Whisper endpoint to transcribe audio.
  /// Replace with your actual code for the chosen whisper API endpoint & parameters.
  Future<String> _transcribeAudioWithOpenAI(List<int> audioBytes) async {
    // OpenAI Whisper for audio transcription
    const whisperUrl = "https://api.openai.com/v1/audio/transcriptions";

    // Prepare request
    final request = http.MultipartRequest('POST', Uri.parse(whisperUrl))
      ..headers['Authorization'] = 'Bearer $openAiApiKey'
      // Adjust model as needed (whisper-1, etc.)
      ..fields['model'] = 'whisper-1'
      ..files.add(http.MultipartFile.fromBytes('file', audioBytes,
          filename: 'audio.wav'));

    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final decode = jsonDecode(responseString) as Map<String, dynamic>;
      return decode['text'] ?? '';
    } else {
      debugPrint("Whisper request failed: $responseString");
      return '';
    }
  }

  /// Example of calling GPT endpoint to do text processing (summary, compliance, etc.)
  /// using OpenAI's ChatCompletion or Completion API. This is minimal; adapt as needed.
  Future<String> _chatGptProcess(String transcript, String prompt) async {
    const chatGptUrl = "https://api.openai.com/v1/chat/completions";
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openAiApiKey',
    };

    // Basic ChatCompletion example
    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a helpful AI assistant."},
        {"role": "user", "content": "$prompt\n\n$transcript"}
      ]
    });

    final response = await http.post(Uri.parse(chatGptUrl),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'] ?? '';
      }
    }
    debugPrint("ChatCompletion request failed: ${response.body}");
    return '';
  }

  /// Captures audio data from the device's microphone.
  Stream<List<int>> _captureAudioFromMicrophone() async* {
    if (await AudioRecorder.hasPermissions) {
      await AudioRecorder.start();
      while (_isRecording) {
        final recording = await AudioRecorder.current();
        yield recording.buffer;
        await Future.delayed(const Duration(milliseconds: 200));
      }
      await AudioRecorder.stop();
    } else {
      throw Exception('Microphone permission not granted');
    }
  }
}