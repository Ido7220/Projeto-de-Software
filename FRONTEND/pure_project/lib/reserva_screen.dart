import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservaScreen extends StatefulWidget {
  const ReservaScreen({super.key});

  @override
  State<ReservaScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ReservaScreen> {
  final _supabase = Supabase.instance.client;

  final _servicoController = TextEditingController();
  final _localController = TextEditingController();

  List<Map<String, dynamic>> _reservas = [];
  bool _carregando = false;
  int? _idReservaEmEdicao;

  @override
  void initState() {
    super.initState();
    _listarReservas();
  }

  Future<void> _listarReservas() async {
    setState(() => _carregando = true);
    try {
      final dados = await _supabase
          .from('reservas')
          .select()
          .order('id', ascending: false);
      setState(() {
        _reservas = List<Map<String, dynamic>>.from(dados);
      });
    } catch (erro) {
      _mostrarAlerta('Erro ao carregar dados: $erro');
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _salvarReserva() async {
    if (_servicoController.text.isEmpty || _localController.text.isEmpty) {
      _mostrarAlerta('Por favor, preencha todos os campos!');
      return;
    }

    setState(() => _carregando = true);

    final dadosParaSubmeter = {
      'servico_name': _servicoController.text.trim(),
      'local': _localController.text.trim(),
      'data_horario': DateTime.now().toIso8601String(),
    };

    try {
      if (_idReservaEmEdicao == null) {
        await _supabase.from('reservas').insert(dadosParaSubmeter);
        _mostrarAlerta('Reserva criada com sucesso!', sucesso: true);
      } else {
        await _supabase
            .from('reservas')
            .update(dadosParaSubmeter)
            .eq('id', _idReservaEmEdicao!);
        _mostrarAlerta('Reserva atualizada com sucesso!', sucesso: true);
      }

      _limparFormulario();
      _listarReservas();
    } catch (erro) {
      _mostrarAlerta('Erro ao guardar: $erro');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _prepararEdicao(Map<String, dynamic> reserva) {
    setState(() {
      _idReservaEmEdicao = reserva['id'];
      _servicoController.text = reserva['servico_name'] ?? '';
      _localController.text = reserva['local'] ?? '';
    });
  }

  Future<void> _eliminarReserva(int id) async {
    setState(() => _carregando = true);
    try {
      await _supabase.from('reservas').delete().eq('id', id);
      _mostrarAlerta('Reserva removida com sucesso!', sucesso: true);
      _listarReservas();
    } catch (erro) {
      _mostrarAlerta('Erro ao eliminar: $erro');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _limparFormulario() {
    _servicoController.clear();
    _localController.clear();
    setState(() {
      _idReservaEmEdicao = null;
    });
  }

  void _mostrarAlerta(String texto, {bool sucesso = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: sucesso ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _servicoController.dispose();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PURE - Gestão de Reservas (CRUD)'),
        actions: [
          if (_idReservaEmEdicao != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _limparFormulario,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _servicoController,
              decoration: const InputDecoration(
                labelText: 'Nome do Serviço Esportivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _localController,
              decoration: const InputDecoration(
                labelText: 'Local / Quadra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregando ? null : _salvarReserva,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _idReservaEmEdicao == null
                    ? 'Adicionar Reserva'
                    : 'Atualizar Reserva',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reservas Registadas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: _carregando && _reservas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _reservas.isEmpty
                  ? const Center(child: Text('Nenhum agendamento encontrado.'))
                  : ListView.builder(
                      itemCount: _reservas.length,
                      itemBuilder: (context, index) {
                        final item = _reservas[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(item['servico_name'] ?? 'Serviço'),
                            subtitle: Text(
                              'Local: ${item['local']}\nStatus: ${item['status']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () => _prepararEdicao(item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _eliminarReserva(item['id']),
                                ),
                              ],
                            ),
                          ),
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
