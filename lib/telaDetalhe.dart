import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'traducao.dart';

class TelaDetalhe extends StatelessWidget {
  final String id;
  final Map<String, dynamic> dados;
  const TelaDetalhe({super.key, required this.id, required this.dados});

  String _fone(String t) {
    if (t.length == 11) {
      return '(${t.substring(0, 2)}) ${t.substring(2, 7)}-${t.substring(7)}';
    }
    if (t.length == 10) {
      return '(${t.substring(0, 2)}) ${t.substring(2, 6)}-${t.substring(6)}';
    }
    return t;
  }

  String? _data(dynamic ts) {
    if (ts is! Timestamp) return null;
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String? _simNao(dynamic v) => v is bool ? (v ? 'Sim' : 'Não') : null;
  Future<void> _excluir(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cliente?'),
        content: Text(
          '${dados['nome'] ?? 'Este animal'} será removido do cadastro. '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await FirebaseFirestore.instance.collection('animais').doc(id).delete();
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }

  Widget _bloco(
    BuildContext context,
    String titulo,
    List<List<String?>> itens,
  ) {
    final visiveis = itens
        .where((i) => i[1] != null && i[1]!.isNotEmpty)
        .toList();
    if (visiveis.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            for (final i in visiveis)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        i[0]!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    Expanded(child: Text(i[1]!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagemUrl = dados['imagemUrl'] as String?;
    final peso = dados['pesoAtual'];

    return Scaffold(
      appBar: AppBar(
        title: Text(dados['nome'] ?? 'Animal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir cliente',
            onPressed: () => _excluir(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (imagemUrl != null)
            Container(
              height: 240,
              color: Colors.grey.shade200,
              child: Image.network(
                imagemUrl,
                fit: BoxFit.contain,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.pets, size: 48)),
              ),
            ),
          _bloco(context, 'Animal', [
            ['Nome', dados['nome']],
            ['Raça', dados['raca']],
            ['Idade', dados['idade'] != null ? '${dados['idade']} anos' : null],
            ['Sexo', dados['sexo']],
            ['Castrado(a)', _simNao(dados['castrado'])],
            ['Peso atual', peso != null ? '$peso kg' : null],
            ['Cadastrado em', _data(dados['criadoEm'])],
          ]),
          _bloco(context, 'Tutor', [
            ['Nome', dados['tutor']],
            [
              'Telefone',
              dados['telefone'] != null ? _fone(dados['telefone']) : null,
            ],
          ]),
          _bloco(context, 'Saúde', [
            ['Vacinas em dia', _simNao(dados['vacinasEmDia'])],
            ['Alergias', dados['alergias']],
            ['Observações', dados['observacoes']],
          ]),
          _bloco(context, 'Sobre a raça', [
            ['Temperamento', Traducao.temperamento(dados['temperamento'])],
            ['Expectativa de vida', Traducao.vida(dados['vida'])],
            ['Peso', Traducao.comUnidade(Traducao.medida(dados['peso']), 'kg')],
            [
              'Altura',
              Traducao.comUnidade(Traducao.medida(dados['altura']), 'cm'),
            ],
            ['Grupo', Traducao.grupo(dados['grupo'])],
            ['Origem', Traducao.origem(dados['origem'])],
          ]),
        ],
      ),
    );
  }
}
