import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'servicoDog.dart';
import 'telaRaca.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _raca = TextEditingController();
  final _idade = TextEditingController();
  bool _salvando = false;
  Raca? _racaEscolhida;

  Future<void> _buscarRaca() async {
    final r = await Navigator.push<Raca>(
      context,
      MaterialPageRoute(builder: (_) => const TelaRacas(selecionar: true)),
    );
    if (r != null) {
      setState(() {
        _racaEscolhida = r;
        _raca.text = r.nome;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    try {
      await FirebaseFirestore.instance.collection('animais').add({
        'nome': _nome.text.trim(),
        'raca': _raca.text.trim(),
        'idade': int.parse(_idade.text),
        ...(_racaEscolhida?.toMap() ?? {}),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _raca.dispose();
    _idade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _racaEscolhida;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo animal'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _raca,
                onChanged: (_) => setState(() => _racaEscolhida = null),
                decoration: InputDecoration(
                  labelText: 'Raça',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Buscar raça na API',
                    onPressed: _buscarRaca,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a raça' : null,
              ),
              if (r != null)
                Card(
                  margin: const EdgeInsets.only(top: 12),
                  child: ListTile(
                    leading: r.imagemUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(r.imagemUrl!),
                          )
                        : const CircleAvatar(child: Icon(Icons.pets)),
                    title: Text(r.nome),
                    subtitle: Text(r.temperamento ?? 'Sem informações extras'),
                  ),
                ),
              TextFormField(
                controller: _idade,
                decoration: const InputDecoration(labelText: 'Idade (anos)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Informe um número' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
