import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart'; // Importar Firebase Core
import 'app/app_state.dart';
import 'config/env_constants.dart';
import 'dashboard/controllers/audio_handler.dart';

late MyAudioHandler audioHandler;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: 'assets/.env');
    EnvConstants.init(dotenv.env);
  } catch (e) {
    debugPrint('Error loading .env: $e');
    // Inicializar con valores por defecto si falla .env
    EnvConstants.init({});
  }

  // Inicializar Firebase
  try {
    // Nota: Para un entorno real, idealmente usarías firebase_options.dart generado por flutterfire configure
    // Si no tienes firebase_options.dart, Firebase tratará de leer google-services.json (Android) o GoogleService-Info.plist (iOS)
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  // Inicializar AudioService ANTES de runApp para evitar LateInitializationError
  // en los controladores que dependen de 'audioHandler'.
  try {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.lanacion.radio.audio',
        androidNotificationChannelName: 'La Nación Radio',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
        androidNotificationClickStartsActivity: true,
        androidNotificationIcon: 'drawable/ic_notification',
      ),
    );
  } catch (e) {
    debugPrint('Error initializing AudioService: $e');
    // Fallback crítico: La app debe iniciar incluso si el audio falla
    // Instanciamos el handler directamente (aunque AudioService no funcione al 100%)
    // para que los controladores no reciban null/late error.
    audioHandler = MyAudioHandler();
  }

  runApp(const AppState());
}
