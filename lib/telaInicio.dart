import 'package:flutter/material.dart';

import 'telaCadastro.dart';
import 'telaHome.dart';
import 'telaRaca.dart';

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  void _abrir(BuildContext context, Widget tela) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Icon(Icons.pets, size: 56, color: cor),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo(a)!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O que você deseja fazer?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                _Opcao(
                  icone: Icons.people_outline,
                  titulo: 'Ver clientes',
                  descricao: 'Consulte os animais cadastrados',
                  onTap: () => _abrir(context, const TelaHome()),
                ),
                _Opcao(
                  icone: Icons.add_circle_outline,
                  titulo: 'Cadastrar cliente',
                  descricao: 'Registre um novo animal e seu tutor',
                  onTap: () => _abrir(context, const TelaCadastro()),
                ),
                _Opcao(
                  icone: Icons.search,
                  titulo: 'Pesquisar raças',
                  descricao: 'Veja temperamento, porte e expectativa de vida',
                  onTap: () => _abrir(context, const TelaRacas()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Opcao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback onTap;

  const _Opcao({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descricao,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
