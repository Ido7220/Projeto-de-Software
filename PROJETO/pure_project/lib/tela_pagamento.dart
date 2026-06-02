import 'package:flutter/material.dart';

class TelaPagamento extends StatefulWidget {
  const TelaPagamento({super.key});

  @override
  State<TelaPagamento> createState() => _TelaPagamentoState();
}

class _TelaPagamentoState extends State<TelaPagamento> {
  final _numeroController = TextEditingController();
  final _nomeController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _numeroController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('tela pagamento')),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          Column(
            children: [
              _campos(
                _numeroController,
                'Número do Cartão',
                '0000 0000 0000 0000',
                Icons.credit_card,
                19,
              ),
              _campos(
                _nomeController,
                'Nome no cartão',
                'Ex: JOAO SILVA',
                Icons.abc,
                200,
              ),
              _campos(
                _validadeController,
                'Validade',
                'MM/AA',
                Icons.calendar_today,
                5,
              ),
              _campos(_cvvController, 'CVV', '123', Icons.security, 3),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _campos(
  TextEditingController controller,
  String texto,
  String texto2,
  IconData icone,
  int tamanho,
) {
  return Padding(
    padding: EdgeInsetsGeometry.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      maxLength: tamanho,
      decoration: InputDecoration(
        labelText: texto,
        hintText: texto2,
        prefixIcon: Icon(icone, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        counterText: "",
      ),
    ),
  );
}
