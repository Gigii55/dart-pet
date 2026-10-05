import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'telaCadastro.dart';
import 'telaRaca.dart';
import 'traducao.dart';
import 'fotoCircular.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Animais'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar raça',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaRacas()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animais').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum animal cadastrado ainda.'));
          }

          final animais = snapshot.data!.docs;

          return ListView.builder(
            itemCount: animais.length,
            itemBuilder: (context, index) {
              final dados = animais[index].data() as Map<String, dynamic>;

              final nome = dados['nome'] ?? 'Sem nome';
              final raca = dados['raca'] ?? 'Raça não informada';
              final idade = dados['idade']?.toString() ?? '?';
              final imagemUrl = dados['imagemUrl'] as String?;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: FotoCircular(url: imagemUrl),
                  title: Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text('$raca • $idade anos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    final temperamento = Traducao.temperamento(
                      dados['temperamento'],
                    );
                    final vida = Traducao.vida(dados['vida']);
                    final peso = Traducao.comUnidade(
                      Traducao.medida(dados['peso']),
                      'kg',
                    );
                    final altura = Traducao.comUnidade(
                      Traducao.medida(dados['altura']),
                      'cm',
                    );
                    final grupo = Traducao.grupo(dados['grupo']);
                    final origem = Traducao.origem(dados['origem']);

                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nome,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Raça: $raca'),
                            Text('Idade: $idade anos'),
                            if (temperamento != null)
                              Text('Temperamento: $temperamento'),
                            if (vida != null)
                              Text('Expectativa de vida: $vida'),
                            if (peso != null) Text('Peso: $peso'),
                            if (altura != null) Text('Altura: $altura'),
                            if (grupo != null) Text('Grupo: $grupo'),
                            if (origem != null) Text('Origem: $origem'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelaCadastro()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
