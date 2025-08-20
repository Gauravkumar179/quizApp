import 'package:firebase_core/firebase_core.dart';
import 'package:quizapp/firebase_options.dart';

class FirebaseInitializer {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
