import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fotoCircular.dart';
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
  final _pesoAtual = TextEditingController();
  final _tutor = TextEditingController();
  final _telefone = TextEditingController();
  final _alergias = TextEditingController();
  final _obs = TextEditingController();

  String? _sexo;
  bool _castrado = false;
  bool _vacinas = false;
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

    final peso = double.tryParse(_pesoAtual.text.replaceAll(',', '.'));

    try {
      await FirebaseFirestore.instance.collection('animais').add({
        'nome': _nome.text.trim(),
        'raca': _raca.text.trim(),
        'idade': int.parse(_idade.text),
        'sexo': _sexo,
        'castrado': _castrado,
        if (peso != null) 'pesoAtual': peso,
        'tutor': _tutor.text.trim(),
        'telefone': _telefone.text.trim(),
        'vacinasEmDia': _vacinas,
        if (_alergias.text.trim().isNotEmpty) 'alergias': _alergias.text.trim(),
        if (_obs.text.trim().isNotEmpty) 'observacoes': _obs.text.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
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
    for (final c in [
      _nome,
      _raca,
      _idade,
      _pesoAtual,
      _tutor,
      _telefone,
      _alergias,
      _obs,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _secao(String titulo) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(
      titulo,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

  static const _espaco = SizedBox(height: 12);

  String? _obrigatorio(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  @override
  Widget build(BuildContext context) {
    final r = _racaEscolhida;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo animal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            _secao('Animal'),
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => _obrigatorio(v, 'Informe o nome'),
            ),
            _espaco,
            TextFormField(
              controller: _raca,
              onChanged: (_) => setState(() => _racaEscolhida = null),
              decoration: InputDecoration(
                labelText: 'Raça',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar raça',
                  onPressed: _buscarRaca,
                ),
              ),
              validator: (v) => _obrigatorio(v, 'Informe a raça'),
            ),
            if (r != null)
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  leading: FotoCircular(url: r.imagemUrl),
                  title: Text(r.nome),
                  subtitle: Text(
                    r.temperamento ?? 'Sem informações extras',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            _espaco,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _idade,
                    decoration: const InputDecoration(
                      labelText: 'Idade (anos)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => int.tryParse(v ?? '') == null
                        ? 'Informe a idade'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pesoAtual,
                    decoration: const InputDecoration(
                      labelText: 'Peso atual',
                      suffixText: 'kg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            _espaco,
            DropdownButtonFormField<String>(
              value: _sexo,
              decoration: const InputDecoration(labelText: 'Sexo'),
              items: const [
                DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
              ],
              onChanged: (v) => setState(() => _sexo = v),
              validator: (v) => v == null ? 'Selecione o sexo' : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Castrado(a)'),
              value: _castrado,
              onChanged: (v) => setState(() => _castrado = v),
            ),

            _secao('Tutor'),
            TextFormField(
              controller: _tutor,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome do tutor'),
              validator: (v) => _obrigatorio(v, 'Informe o tutor'),
            ),
            _espaco,
            TextFormField(
              controller: _telefone,
              decoration: const InputDecoration(
                labelText: 'Telefone (com DDD)',
                hintText: '44999998888',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (v) =>
                  (v == null || v.length < 10) ? 'Telefone inválido' : null,
            ),

            _secao('Saúde'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vacinas em dia'),
              value: _vacinas,
              onChanged: (v) => setState(() => _vacinas = v),
            ),
            _espaco,
            TextFormField(
              controller: _alergias,
              decoration: const InputDecoration(
                labelText: 'Alergias / condições',
                hintText: 'Ex: alergia a dipirona',
              ),
            ),
            _espaco,
            TextFormField(
              controller: _obs,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),
            FilledButton(
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
    );
  }
}
