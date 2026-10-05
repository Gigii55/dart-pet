import 'package:flutter/material.dart';

class FotoCircular extends StatelessWidget {
  final String? url;
  final double raio;

  const FotoCircular({super.key, this.url, this.raio = 20});

  Widget _patinha() => Container(
    color: Colors.blue,
    child: Icon(Icons.pets, color: Colors.white, size: raio),
  );

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: raio * 2,
        height: raio * 2,
        child: url == null
            ? _patinha()
            : Image.network(
                url!,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, __, ___) => _patinha(),
              ),
      ),
    );
  }
}
