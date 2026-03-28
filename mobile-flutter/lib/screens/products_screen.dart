import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    final auth = context.read<AuthProvider>();
    return context.read<ProductsProvider>().load(
      auth.token!,
      auth.username!,
      auth.role ?? 'USER',
    );
  }

  Future<void> _showCreateDialog() async {
    final nameCtrl  = TextEditingController();
    final descCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final formKey   = GlobalKey<FormState>();
    bool submitting  = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF30363D)),
          ),
          title: const Text(
            'Nuevo producto',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 360,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(nameCtrl,  'Nombre *',      hint: 'Ej. EcoBotella Acero', required: true),
                  const SizedBox(height: 10),
                  _dialogField(descCtrl,  'Descripción',   hint: 'Descripción breve'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _dialogField(priceCtrl, 'Precio *', hint: '0.00',
                        keyboardType: TextInputType.number, required: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _dialogField(stockCtrl, 'Stock', hint: '0',
                        keyboardType: TextInputType.number)),
                  ]),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8B949E))),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDState(() => submitting = true);
                      try {
                        final auth = context.read<AuthProvider>();
                        await context.read<ProductsProvider>().createProduct(
                          token:       auth.token!,
                          name:        nameCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                          price:       double.parse(priceCtrl.text),
                          stock:       int.tryParse(stockCtrl.text) ?? 0,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setDState(() => submitting = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Error al crear producto')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: const Color(0xFF0D1117),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: submitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D1117)))
                  : const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pp   = context.watch<ProductsProvider>();
    final stats = pp.stats;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.eco, color: Color(0xFF2ECC71), size: 20),
            const SizedBox(width: 8),
            const Text('Catálogo', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            if (stats != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff2ecc7120),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff2ecc7140)),
                ),
                child: Text(
                  '${auth.username} (${stats.productCount})',
                  style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF8B949E)),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B949E)),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF30363D)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: const Color(0xFF0D1117),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: pp.loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
          : pp.error != null
              ? Center(child: Text(pp.error!, style: const TextStyle(color: Color(0xFFFF7171))))
              : pp.products.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📦', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 8),
                          Text('No hay productos. ¡Crea el primero!',
                              style: TextStyle(color: Color(0xFF8B949E))),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF2ECC71),
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: pp.products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ProductCard(product: pp.products[i]),
                      ),
                    ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label, {
    String hint = '',
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF8B949E)),
            filled: true,
            fillColor: const Color(0xFF0D1117),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF30363D))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2ECC71))),
          ),
          validator: required ? (v) => v!.isEmpty ? 'Requerido' : null : null,
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                if (product.description != null) ...[
                  const SizedBox(height: 3),
                  Text(product.description!,
                      style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 12, color: Color(0xFF8B949E)),
                    const SizedBox(width: 4),
                    const Text('Creado por ', style: TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
                    Text(product.creatorUsername,
                        style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${product.stock} en stock',
                  style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
