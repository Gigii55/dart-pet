import 'package:flutter/material.dart';
import 'traducao.dart';
import 'servicoDog.dart';

class TelaRacas extends StatefulWidget {
  final bool selecionar;
  const TelaRacas({super.key, this.selecionar = false});

  @override
  State<TelaRacas> createState() => _TelaRacasState();
}

class _TelaRacasState extends State<TelaRacas> {
  final _busca = TextEditingController();
  List<Raca>? _racas;
  bool _carregando = false;
  String? _erro;

  Future<void> _buscar() async {
    final termo = _busca.text.trim();
    if (termo.isEmpty) return;

    setState(() {
      _carregando = true;
      _erro = null;
      _racas = null;
    });

    try {
      final r = await ServicoDog.buscar(termo);
      setState(() => _racas = r);
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      setState(() => _carregando = false);
    }
  }

  Widget _linha(String rotulo, String? valor) {
    if (valor == null || valor.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$rotulo: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selecionar ? 'Escolher raça' : 'Buscar raça'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busca,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                labelText: 'Nome da raça (ex: beagle, husky, pastor alemão)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscar,
                ),
              ),
            ),
          ),
          if (_carregando) const CircularProgressIndicator(),
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_erro!, style: const TextStyle(color: Colors.red)),
            ),
          if (_racas != null && _racas!.isEmpty)
            const Text('Nenhuma raça encontrada.'),
          if (_racas != null)
            Expanded(
              child: ListView.builder(
                itemCount: _racas!.length,
                itemBuilder: (context, i) {
                  final r = _racas![i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.selecionar
                          ? () => Navigator.pop(context, r)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (r.imagemUrl != null)
                            Image.network(
                              r.imagemUrl!,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.prefer,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                height: 80,
                                child: Center(
                                  child: Icon(Icons.pets, size: 40),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.nome,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _linha('Temperamento', r.temperamento),
                                _linha('Expectativa de vida', r.vida),
                                _linha(
                                  'Peso',
                                  Traducao.comUnidade(r.peso, 'kg'),
                                ),
                                _linha(
                                  'Altura',
                                  Traducao.comUnidade(r.altura, 'cm'),
                                ),
                                _linha('Grupo', r.grupo),
                                _linha('Origem', r.origem),
                              ],
                            ),
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
    );
  }
}
