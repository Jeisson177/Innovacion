import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tienda Doña Msarta'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Acción del carrito
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Barra de búsqueda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ingresa producto/tienda',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Banner de promoción
            Container(
              color: Colors.green[200],
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.notifications),
                  SizedBox(width: 8),
                  Expanded(child: Text('Martes de limpieza - 2x1 en jabones y detergentes seleccionados')),
                  TextButton(
                    onPressed: () {
                      // Ver más acción
                    },
                    child: Text('Ver más'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Categorías
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                categoryIcon(Icons.local_laundry_service, 'Aseo'),
                categoryIcon(Icons.fastfood, 'Comida'),
                categoryIcon(Icons.health_and_safety, 'Salud'),
              ],
            ),
            SizedBox(height: 16),
            // Favoritos
            Expanded(
              child: ListView(
                children: [
                  favoriteItem('Chocolatina Jet leche', 'El gran bodega', '\$14.500','assets/images/colcafe.webp'),
                  favoriteItem('Colcafé CAPPUCCINO Vainilla', 'Oferntes', '\$5.850','assets/images/colcafe.webp'),
                  favoriteItem('Huevos', 'Don José', '\$10.000','assets/images/colcafe.webp'),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
        currentIndex: 0, // Índice de la pestaña seleccionada
        onTap: (index) {
          // Lógica para cambiar entre pestañas
        },
        backgroundColor: const Color.fromARGB(85, 150, 137, 137),
      ),
    
    );
  }

  Widget categoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 40),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

 Widget favoriteItem(String product, String store, String price, String imageUrl) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // Bordes redondeados
    ),
    elevation: 4, // Sombra del card
    margin: EdgeInsets.symmetric(vertical: 8.0),
    child: ListTile(
      contentPadding: EdgeInsets.all(12.0),
      leading: Image.network(
        imageUrl, // URL de la imagen
        width: 60, // Tamaño de la imagen
        height: 60,
        fit: BoxFit.cover,
      ),
      title: Text(
        product,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Tienda: $store'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            price,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.green),
            onPressed: () {
              // Acción para agregar al carrito
            },
          ),
        ],
      ),
    ),
  );
}



}
