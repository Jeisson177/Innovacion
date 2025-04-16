import 'package:flutter/material.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:marketcheap/services/ProductoService.dart';

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  _EditarProductoScreenState createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  late final TextEditingController _nombreController;
  late final TextEditingController _precioController;
  late final TextEditingController _descripcionController;
  late final GlobalKey<FormState> _formKey;
  final ProductoService _productoService = ProductoService();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nombreController = TextEditingController();
    _precioController = TextEditingController();
    _descripcionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Llenar los controladores después de initState
    _nombreController.text = widget.producto.nombre;
    _precioController.text = widget.producto.precio.toString();
    _descripcionController.text = widget.producto.descripcion;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _actualizarProducto() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final productoActualizado = Producto(
          id: widget.producto.id,
          nombre: _nombreController.text,
          precio: double.tryParse(_precioController.text) ?? widget.producto.precio,
          descripcion: _descripcionController.text,
          marca: widget.producto.marca,
          tienda: widget.producto.tienda,
          categoria: widget.producto.categoria,
          cantidadDisponible: widget.producto.cantidadDisponible,
          imagenUrl: widget.producto.imagenUrl,
          valoraciones: widget.producto.valoraciones,
        );

        await _productoService.updateProducto(productoActualizado);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado correctamente')),
        );
        
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar producto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _actualizarProducto,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingrese un precio';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}