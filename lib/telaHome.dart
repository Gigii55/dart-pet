import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'fotoCircular.dart';
import 'telaCadastro.dart';
import 'telaDetalhe.dart';
import 'telaRaca.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Consultar raça',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaRacas()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animais')
            .orderBy('nome')
            .snapshots(),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: animais.length,
            itemBuilder: (context, index) {
              final dados = animais[index].data() as Map<String, dynamic>;

              final nome = dados['nome'] ?? 'Sem nome';
              final raca = dados['raca'] ?? 'Raça não informada';
              final idade = dados['idade']?.toString() ?? '?';
              final tutor = dados['tutor'] as String?;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: FotoCircular(url: dados['imagemUrl'], raio: 24),
                  title: Text(
                    nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    tutor != null
                        ? '$raca • $idade anos\nTutor: $tutor'
                        : '$raca • $idade anos',
                  ),
                  isThreeLine: tutor != null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TelaDetalhe(id: animais[index].id, dados: dados),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelaCadastro()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo animal'),
      ),
    );
  }
}
