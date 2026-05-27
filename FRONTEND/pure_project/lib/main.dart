import 'package:flutter/material.dart';
import 'package:pure_project/cadastro_screen.dart';
import 'package:pure_project/reserva_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ydkozmcedyjagmagnjlo.supabase.co',
    anonKey: 'sb_publishable_CnP7uYL54xJz2KitAI-I2w_K1daW-s8',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: CadastroScreen(),
      routes: {
        '/home': (context) => const ReservaScreen(),
        '/cadastro': (context) => const CadastroScreen(),
      },
    );
  }
}
