import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_ui.dart';

/// Мини-витрина: Каталог → Товар → Корзина. При открытии каждого экрана
/// вызывается [Carrot.trackScreen], как это делал бы хост в реальном приложении.
class ScreenTrackingScreen extends StatefulWidget {
  const ScreenTrackingScreen({super.key});

  @override
  State<ScreenTrackingScreen> createState() => _ScreenTrackingScreenState();
}

class _ScreenTrackingScreenState extends State<ScreenTrackingScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _trackCustom() async {
    final name = _nameController.text.trim();
    try {
      await Carrot.trackScreen(name);
    } catch (e) {
      if (mounted) showSnack(context, 'Ошибка: $e');
      return;
    }
    if (!mounted) return;
    showSnack(context, 'trackScreen: $name');
    setState(() => _nameController.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Трекинг экранов')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SectionHeader('Витрина'),
          SettingsGroup(
            children: [
              ListTile(
                title: const Text('Каталог'),
                subtitle: const Text(
                  'Каталог → Товар → Корзина: trackScreen на каждом переходе',
                ),
                trailing: const Chevron(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _CatalogScreen()),
                ),
              ),
            ],
          ),
          const SectionHeader('Произвольный экран'),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Имя экрана',
              hintText: 'например, CheckoutScreen',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Отправить trackScreen'),
            onPressed: _nameController.text.trim().isEmpty ? null : _trackCustom,
          ),
        ],
      ),
    );
  }
}

class _TrackedScreen extends StatefulWidget {
  const _TrackedScreen({
    required this.screenName,
    required this.title,
    required this.children,
  });

  final String screenName;
  final String title;
  final List<Widget> children;

  @override
  State<_TrackedScreen> createState() => _TrackedScreenState();
}

class _TrackedScreenState extends State<_TrackedScreen> {
  @override
  void initState() {
    super.initState();
    _track();
  }

  Future<void> _track() async {
    try {
      await Carrot.trackScreen(widget.screenName);
    } catch (e) {
      debugPrint('trackScreen error: $e');
    }
    if (mounted) showSnack(context, 'trackScreen: ${widget.screenName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: widget.children,
      ),
    );
  }
}

class _Product {
  const _Product(this.name, this.price);

  final String name;
  final String price;
}

const _products = [
  _Product('Кроссовки Runner 42', '4 990 ₽'),
  _Product('Футболка Basic', '1 290 ₽'),
  _Product('Рюкзак City 20L', '3 490 ₽'),
];

class _CatalogScreen extends StatelessWidget {
  const _CatalogScreen();

  @override
  Widget build(BuildContext context) {
    return _TrackedScreen(
      screenName: 'CatalogScreen',
      title: 'Каталог',
      children: [
        const SectionHeader('Товары'),
        SettingsGroup(
          children: [
            for (final product in _products)
              ListTile(
                title: Text(product.name),
                subtitle: Text(product.price),
                trailing: const Chevron(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _ProductScreen(product),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProductScreen extends StatelessWidget {
  const _ProductScreen(this.product);

  final _Product product;

  @override
  Widget build(BuildContext context) {
    return _TrackedScreen(
      screenName: 'ProductScreen',
      title: 'Товар',
      children: [
        const SectionHeader('Товар'),
        SettingsGroup(
          children: [
            ListTile(
              title: Text(product.name),
              subtitle: const Text(
                'Демо-карточка товара. Открытие этого экрана уже затрекано '
                'как ProductScreen.',
              ),
              trailing: Text(product.price),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _CartScreen(product)),
          ),
          child: const Text('В корзину'),
        ),
      ],
    );
  }
}

class _CartScreen extends StatelessWidget {
  const _CartScreen(this.product);

  final _Product product;

  @override
  Widget build(BuildContext context) {
    return _TrackedScreen(
      screenName: 'CartScreen',
      title: 'Корзина',
      children: [
        const SectionHeader('Корзина'),
        SettingsGroup(
          children: [
            ListTile(
              title: Text(product.name),
              subtitle: const Text('1 шт.'),
              trailing: Text(product.price),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Конец витрины: CatalogScreen → ProductScreen → CartScreen '
          'уже отправлены в SDK.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
