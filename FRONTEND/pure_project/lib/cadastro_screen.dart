import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;

  String _perfilSelecionado = 'USUARIO';

  final List<Map<String, String>> _perfis = [
    {'valor': 'USUARIO', 'label': 'Usuário'},
    {'valor': 'INSTRUTOR', 'label': 'Instrutor'},
    {'valor': 'ADMINISTRADOR', 'label': 'Administrador'},
  ];

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final resposta = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      if (resposta.user != null) {
        await Supabase.instance.client.from('usuarios').insert({
          'id': resposta.user!.id,
          'nome': _nomeController.text.trim(),
          'email': _emailController.text.trim(),
          'perfil': _perfilSelecionado,
          'ativo': true,
        });

        if (mounted) {
          _mostrarSucesso('Cadastro realizado com sucesso!');
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.pop(context);
        }
      }
    } on AuthException catch (erro) {
      if (mounted) _mostrarErro(erro.message);
    } catch (erro) {
      if (mounted) _mostrarErro('Erro ao cadastrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),

          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),

            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Criar conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Preencha os dados para se cadastrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  SizedBox(height: 28),

                  _label('Nome completo'),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      'Seu nome completo',
                      Icons.person_outlined,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) return 'Informe seu nome';
                      if (valor.length < 3) return 'Nome muito curto';
                      return null;
                    },
                  ),
                  SizedBox(height: 18),

                  _label('E-mail'),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      'seu@email.com',
                      Icons.email_outlined,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) return 'Informe o e-mail';
                      if (!valor.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  SizedBox(height: 18),
                  _label('Senha'),
                  SizedBox(height: 6),
                  TextFormField(
                    controller: _senhaController,
                    decoration: _inputDecoration(
                      'Minímo 6 carateres',
                      Icons.lock_outlined,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) return 'Informe a senha';
                      if (valor.length < 3) return 'Senha deve ter ao menos 3';
                      return null;
                    },
                  ),
                  SizedBox(height: 18),
                  _label('Tipo de usuário'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _perfilSelecionado,
                    decoration: _inputDecoration('', Icons.person_outlined),
                    items: _perfis.map((perfil) {
                      return DropdownMenuItem<String>(
                        value: perfil['valor'],
                        child: Text(perfil['label']!),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() => _perfilSelecionado = valor!);
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _cadastrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Cadastrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Já tenho conta — Fazer login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF444444),
      ),
    );
  }

  InputDecoration _inputDecoration(String texto, IconData icone) {
    return InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icone),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
