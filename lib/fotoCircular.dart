import 'package:flutter/material.dart';

class FotoCircular extends StatelessWidget {
  final String? url;
  final double raio;

  const FotoCircular({super.key, this.url, this.raio = 20});
  Widget _patinha(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.primary,
    child: Icon(Icons.pets, color: Colors.white, size: raio),
  );

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: raio * 2,
        height: raio * 2,
        child: url == null
            ? _patinha(context)
            : Image.network(
                url!,
                key: ValueKey(url),
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, __, ___) => _patinha(context),
              ),
      ),
    );
  }
}
