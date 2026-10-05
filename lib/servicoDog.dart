import 'dart:convert';
import 'traducao.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Raca {
  final String nome;
  final String? temperamento;
  final String? vida;
  final String? peso;
  final String? altura;
  final String? grupo;
  final String? origem;
  final String? imagemUrl;

  Raca({
    required this.nome,
    this.temperamento,
    this.vida,
    this.peso,
    this.altura,
    this.grupo,
    this.origem,
    this.imagemUrl,
  });

  factory Raca.fromJson(Map<String, dynamic> j) {
    String? img = j['image']?['url'];
    if (img == null && j['reference_image_id'] != null) {
      img = 'https://cdn.thedogapi.com/images/${j['reference_image_id']}.jpg';
    }

    return Raca(
      nome: Traducao.nomeRaca(j['name']?.toString() ?? 'Sem nome'),
      temperamento: Traducao.temperamento(j['temperament']?.toString()),
      vida: Traducao.vida(j['life_span']?.toString()),
      peso: Traducao.medida(j['weight']?['metric']?.toString()),
      altura: Traducao.medida(j['height']?['metric']?.toString()),
      grupo: Traducao.grupo(j['breed_group']?.toString()),
      origem: Traducao.origem(j['origin']?.toString()),
      imagemUrl: img,
    );
  }

  Map<String, dynamic> toMap() => {
    if (temperamento != null) 'temperamento': temperamento,
    if (vida != null) 'vida': vida,
    if (peso != null) 'peso': peso,
    if (altura != null) 'altura': altura,
    if (grupo != null) 'grupo': grupo,
    if (origem != null) 'origem': origem,
    if (imagemUrl != null) 'imagemUrl': imagemUrl,
  };
}

class ServicoDog {
  static const _base = 'https://api.thedogapi.com/v1';

  static Map<String, String> get _headers => {
    'x-api-key': dotenv.env['DOG_API_KEY'] ?? '',
  };

  static Future<String?> _urlImagem(String? id) async {
    if (id == null) return null;
    try {
      final r = await http.get(
        Uri.parse('$_base/images/$id'),
        headers: _headers,
      );
      if (r.statusCode == 200) {
        return (jsonDecode(r.body) as Map)['url']?.toString();
      }
    } catch (_) {}
    return null;
  }

  static Future<List<Raca>> buscar(String nome) async {
    final url = Uri.parse(
      '$_base/breeds/search?q=${Uri.encodeQueryComponent(Traducao.termoBusca(nome))}',
    );

    final resposta = await http.get(url, headers: _headers);

    if (resposta.statusCode == 401 || resposta.statusCode == 403) {
      throw Exception('Chave da API inválida. Confira o DOG_API_KEY no .env.');
    }
    if (resposta.statusCode != 200) {
      throw Exception('Erro ${resposta.statusCode}: ${resposta.body}');
    }

    final lista = jsonDecode(resposta.body) as List;

    return Future.wait(
      lista.map((e) async {
        final j = e as Map<String, dynamic>;
        if (j['image']?['url'] == null) {
          final link = await _urlImagem(j['reference_image_id']?.toString());
          if (link != null) j['image'] = {'url': link};
        }
        return Raca.fromJson(j);
      }),
    );
  }
}
