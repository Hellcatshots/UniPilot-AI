import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/groq_service.dart';
import 'services/hybrid_ai_service.dart';
import 'services/university_repository.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auto_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GroqService().init();
  runApp(const UniPilotApp());
}

class UniPilotApp extends StatelessWidget {
  const UniPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UniversityRepository()),
        ChangeNotifierProvider(create: (_) => HybridAiService()),
      ],
      child: MaterialApp(
        title: 'UniPilot AI - Academic & Career Operating System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AutoLoginScreen(),
      ),
    );
  }
}
