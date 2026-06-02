import 'package:flutter/material.dart';
import 'package:pure_project/tela_cadastro.dart';
import 'package:pure_project/tela_login.dart';
import 'package:pure_project/tela_servicos_home.dart';

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
      home: TelaLogin(),
      routes: {
        '/home': (context) => const TelaServicosHome(),
        '/cadastro': (context) => const TelaCadastro(),
        '/login': (context) => const TelaLogin(),
      },
    );
  }
}
