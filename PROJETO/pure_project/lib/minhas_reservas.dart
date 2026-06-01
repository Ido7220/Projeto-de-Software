import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaMinhasReservas extends StatefulWidget {
  const TelaMinhasReservas({super.key});

  @override
  State<TelaMinhasReservas> createState() => _TelaMinhasReservasState();
}

class _TelaMinhasReservasState extends State<TelaMinhasReservas> {
  // 1. Pegamos o ID do utilizador atualmente logado no dispositivo
  final String? _idUsuarioLogado =
      Supabase.instance.client.auth.currentUser?.id;

  late final Stream<List<Map<String, dynamic>>> _minhasReservasStream;

  @override
  void initState() {
    super.initState();
    _minhasReservasStream = Supabase.instance.client
        .from('minhas_reservas')
        .stream(primaryKey: ['id'])
        .eq('user_id', _idUsuarioLogado ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
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
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _minhasReservasStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar as suas reservas.'),
                    );
                  }

                  final reservas = snapshot.data ?? [];

                  if (reservas.isEmpty) {
                    return const Center(
                      child: Text(
                        'Ainda não fez nenhuma reserva.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: reservas.length,
                    itemBuilder: (context, index) {
                      final item = reservas[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            _dado(2, item['esporte']?.toString() ?? '-'),
                            _dado(2, item['data']?.toString() ?? '-'),
                            _dado(2, item['horario']?.toString() ?? '-'),
                            _dado(3, item['instrutor']?.toString() ?? '-'),
                            _dado(3, item['local']?.toString() ?? '-'),
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

  Widget _titulo(int tamanho, String titulo) {
    return Expanded(
      flex: tamanho,
      child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _dado(int tamanho, String valor) {
    return Expanded(flex: tamanho, child: Text(valor));
  }
}
