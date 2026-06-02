import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;

  Future<void> _aoLogar() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      _mostrarAlerta('Preecha todos os campos');
      return;
    }

    setState(() => _carregando = true);

    try {
      final AuthResponse resposta = await Supabase.instance.client.auth
          .signInWithPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );

      if (resposta.user != null) {
        if (!mounted) return;
        _mostrarAlerta('Login realizado com sucesso', sucesso: true);

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (erro) {
      _mostrarAlerta('E-mail ou senha incoreeta');
    } finally {
      setState(() => _carregando = false);
    }
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
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'PURE',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Plataforma Unificada de Reservas Esportivas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 24),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _aoLogar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                  child: const Text('Não tem uma conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
