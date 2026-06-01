import 'package:flutter/material.dart';
import 'package:pure_project/minhas_reservas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaServicosHome extends StatefulWidget {
  const TelaServicosHome({super.key});

  @override
  State<TelaServicosHome> createState() => _TelaServicosHomeState();
}

class _TelaServicosHomeState extends State<TelaServicosHome> {
  final _registrosStream = Supabase.instance.client
      .from('registros_esportes')
      .stream(primaryKey: ['id']);

  Future<void> _deslogar() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
    }
  }

  Future<void> _fazerInscricao(Map<String, dynamic> item) async {
    try {
      final usuario = Supabase.instance.client.auth.currentUser;

      await Supabase.instance.client.from('minhas reservas').insert({
        'user_id': usuario?.id,
        'esporte': item['esporte'],
        'data': item['data'],
        'horario': item['horario'] ?? item['hora'],
        'instrutor': item['instrutor'],
        'local': item['local'],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscrição realizada com sucesso!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaMinhasReservas()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao se inscrever: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'perfil':
                  debugPrint('Navegar para Perfil');
                  break;
                case 'reservas':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaMinhasReservas(),
                    ),
                  );

                  break;
                case 'sair':
                  _deslogar();
                  break;
              }
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'perfil',
                child: ListTile(title: Text('Perfil')),
              ),
              PopupMenuItem<String>(
                value: 'reservas',
                child: ListTile(title: Text('Minhas reservas')),
              ),
              PopupMenuItem<String>(
                value: 'sair',
                child: ListTile(title: Text('Sair')),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _titulo(2, 'Esporte'),
                _titulo(2, 'Data'),
                _titulo(2, 'Hora'),
                _titulo(3, 'Instrutor'),
                _titulo(3, 'Local'),
                _titulo(2, 'Vagas'),
                _titulo(3, 'Inscrever-se'),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _registrosStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar os dados.'),
                    );
                  }

                  final registros = snapshot.data ?? [];

                  if (registros.isEmpty) {
                    return const Center(
                      child: Text('Nenhum esporte registrado.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: registros.length,
                    itemBuilder: (context, index) {
                      final item = registros[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            _dado(2, item['esporte']?.toString() ?? '-'),
                            _dado(2, item['data']?.toString() ?? '-'),
                            _dado(2, item['hora']?.toString() ?? '-'),
                            _dado(3, item['instrutor']?.toString() ?? '-'),
                            _dado(3, item['local']?.toString() ?? '-'),
                            _dado(2, item['vagas']?.toString() ?? '-'),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: () => _fazerInscricao(item),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 0,
                                  ),
                                ),
                                child: const Text(
                                  'Inscrever',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _titulo(int tamanho, String titulo) {
  return Expanded(
    flex: tamanho,
    child: Text(titulo, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _dado(int tamanho, String valor) {
  return Expanded(flex: tamanho, child: Text(valor));
}
