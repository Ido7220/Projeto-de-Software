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

      await Supabase.instance.client.from('minhas_reservas').insert({
        'user_id': usuario?.id,
        'esporte': item['esporte'],
        'data': item['data'],
        'horario': item['hora'],
        'instrutor': item['instrutor'],
        'local': item['local'],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscrição realizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaMinhasReservas()),
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
        title: const Text(
          'Serviços',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFFF6B2C),
        iconTheme: const IconThemeData(color: Colors.white),
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
                      builder: (context) => const TelaMinhasReservas(),
                    ),
                  );
                  break;
                case 'sair':
                  _deslogar();
                  break;
              }
            },
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(
                value: 'perfil',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Perfil'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'reservas',
                child: ListTile(
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text('Minhas reservas'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'sair',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(
                    'Sair',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                _Titulo(flex: 2, texto: 'Esporte'),
                _Titulo(flex: 2, texto: 'Data'),
                _Titulo(flex: 2, texto: 'Hora'),
                _Titulo(flex: 3, texto: 'Instrutor'),
                _Titulo(flex: 3, texto: 'Local'),
                _Titulo(flex: 2, texto: 'Vagas'),
                _Titulo(flex: 3, texto: 'Inscrever-se'),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _registrosStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B2C),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),

                          Text('Erro: ${snapshot.error}'),
                        ],
                      ),
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
                            _Dado(
                              flex: 2,
                              valor: item['esporte']?.toString() ?? '-',
                            ),
                            _Dado(
                              flex: 2,
                              valor: item['data']?.toString() ?? '-',
                            ),
                            _Dado(
                              flex: 2,
                              valor: item['hora']?.toString() ?? '-',
                            ),
                            _Dado(
                              flex: 3,
                              valor: item['instrutor']?.toString() ?? '-',
                            ),
                            _Dado(
                              flex: 3,
                              valor: item['local']?.toString() ?? '-',
                            ),
                            _Dado(
                              flex: 2,
                              valor: item['vagas']?.toString() ?? '-',
                            ),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: () => _fazerInscricao(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B2C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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

class _Titulo extends StatelessWidget {
  final int flex;
  final String texto;

  const _Titulo({required this.flex, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _Dado extends StatelessWidget {
  final int flex;
  final String valor;

  const _Dado({required this.flex, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(valor, style: const TextStyle(fontSize: 13)),
    );
  }
}
