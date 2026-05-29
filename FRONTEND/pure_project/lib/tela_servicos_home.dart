import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
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
                                onPressed: () {
                                  debugPrint(
                                    'Clicou em inscrever no item: ${item['id']}',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
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
