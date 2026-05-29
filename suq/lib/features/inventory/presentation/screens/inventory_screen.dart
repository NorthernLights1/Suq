import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/product.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/inventory_remote.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = ref.watch(lowStockCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            const Tab(text: 'Products'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Stock'),
                  lowStockCount.when(
                    data: (n) => n > 0
                        ? Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('$n',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _ProductsTab(),
          _StockTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProductForm(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProductFormScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

// ─── Products Tab ─────────────────────────────────────────────────────────────

class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    return products.when(
      data: (list) => list.isEmpty
          ? _EmptyProducts()
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _ProductTile(product: list[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
          child: Text('Error: $e', style: AppTextStyles.bodySmall)),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        child: Text(
          product.name[0].toUpperCase(),
          style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(product.name, style: AppTextStyles.body),
      subtitle: Text(
        product.sellingPrice != null
            ? 'ETB ${product.sellingPrice!.toStringAsFixed(2)} · ${product.measurementUnitAbbr}'
            : product.measurementUnitAbbr,
        style: AppTextStyles.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductFormScreen(product: product),
          fullscreenDialog: true,
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text('No products yet', style: AppTextStyles.headline3),
          const SizedBox(height: 4),
          Text('Tap + to add your first product',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ─── Stock Tab ────────────────────────────────────────────────────────────────

class _StockTab extends ConsumerWidget {
  const _StockTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockLevelsProvider);
    return stock.when(
      data: (list) => list.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.scale_outlined,
                      size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 12),
                  Text('No stock recorded', style: AppTextStyles.headline3),
                  const SizedBox(height: 4),
                  Text('Add products first, then set opening stock',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            )
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _StockTile(entry: list[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
          child: Text('Error: $e', style: AppTextStyles.bodySmall)),
    );
  }
}

class _StockTile extends ConsumerWidget {
  const _StockTile({required this.entry});
  final StockEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLow = entry.isLowStock;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isLow
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.primaryLight,
        child: Icon(
          isLow ? Icons.warning_amber_outlined : Icons.inventory_outlined,
          color: isLow ? AppColors.warning : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(entry.productName, style: AppTextStyles.body),
      subtitle: isLow
          ? Text('Low stock — threshold: ${entry.lowStockThreshold} ${entry.unitAbbr}',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.warning))
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${entry.quantity.toStringAsFixed(2)} ${entry.unitAbbr}',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: isLow ? AppColors.warning : AppColors.textPrimary,
            ),
          ),
          Text('in stock', style: AppTextStyles.label),
        ],
      ),
      onTap: () => _showAdjustDialog(context, ref),
    );
  }

  void _showAdjustDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(
        text: entry.quantity.toStringAsFixed(2));
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust: ${entry.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${entry.quantity} ${entry.unitAbbr}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'New quantity', isDense: true),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                  labelText: 'Reason (required)', isDense: true),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (notesCtrl.text.trim().isEmpty) return;
              final newQty =
                  Decimal.tryParse(ctrl.text) ?? entry.quantity;
              Navigator.pop(ctx);
              final ok = await ref
                  .read(stockAdjustmentProvider.notifier)
                  .manualAdjust(
                    productId: entry.productId,
                    newQuantity: newQty,
                    currentQuantity: entry.quantity,
                    notes: notesCtrl.text.trim(),
                  );
              if (context.mounted && !ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Adjustment failed'),
                      backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── Product Form Screen ──────────────────────────────────────────────────────

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});
  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl =
      TextEditingController(text: widget.product?.name ?? '');
  late final _priceCtrl = TextEditingController(
      text: widget.product?.sellingPrice?.toString() ?? '');
  late final _thresholdCtrl = TextEditingController(
      text: widget.product?.lowStockThreshold.toString() ?? '0');
  MeasurementUnit? _selectedUnit;

  bool get _isEdit => widget.product != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a unit of measurement')),
      );
      return;
    }

    final ok = await ref.read(productFormProvider.notifier).save(
          productId: widget.product?.id,
          name: _nameCtrl.text,
          measurementUnitId: _selectedUnit!.id,
          lowStockThreshold:
              Decimal.tryParse(_thresholdCtrl.text) ?? Decimal.zero,
          sellingPrice: _priceCtrl.text.trim().isEmpty
              ? null
              : Decimal.tryParse(_priceCtrl.text),
        );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      final err = ref.read(productFormProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(err?.toString() ?? 'Failed to save'),
            backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deactivate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove product?'),
        content: const Text(
            'The product will be hidden from sales. Historical records are kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final ok = await ref
        .read(productFormProvider.notifier)
        .deactivate(widget.product!.id);
    if (mounted && ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final units = ref.watch(measurementUnitsProvider);
    final loading = ref.watch(productFormProvider).isLoading;

    // Pre-select unit when editing
    units.whenData((list) {
      if (_selectedUnit == null && widget.product != null) {
        final match = list.where(
            (u) => u.id == widget.product!.measurementUnitId);
        if (match.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedUnit = match.first);
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Product' : 'New Product'),
        actions: [
          if (_isEdit)
            TextButton(
              onPressed: _deactivate,
              child: const Text('Remove',
                  style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameCtrl,
                label: 'Product Name',
                autofocus: !_isEdit,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              // Unit of measurement
              units.when(
                data: (list) => DropdownButtonFormField<MeasurementUnit>(
                  initialValue: _selectedUnit,
                  hint: const Text('Unit of measurement'),
                  decoration: const InputDecoration(isDense: false),
                  items: list
                      .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text('${u.name} (${u.abbreviation})')))
                      .toList(),
                  onChanged: (u) => setState(() => _selectedUnit = u),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _priceCtrl,
                label: 'Selling Price (ETB) — optional',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _thresholdCtrl,
                label: 'Low Stock Alert Threshold',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.warning_amber_outlined),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _isEdit ? 'Save Changes' : 'Add Product',
                loading: loading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
