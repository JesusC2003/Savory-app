import 'package:flutter/material.dart';
import 'package:proyecto_savory/UI/home/despensa_page.dart';
import 'package:proyecto_savory/UI/home/perfil_page.dart';
import 'package:proyecto_savory/UI/home/recetas_page.dart';

/// 🌿 HomePage de Savory
/// Incluye navegación inferior, AppBar dinámico y FAB contextual.
/// Autor: Jesús Castillo

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showFabLabel = false;

  // Keys para acceder a los métodos de las páginas
  final GlobalKey<DespensaPageState> _despensaKey = GlobalKey<DespensaPageState>();
  final GlobalKey<RecetasPageState> _recetasKey = GlobalKey<RecetasPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RecetasPage(key: _recetasKey),
      DespensaPage(key: _despensaKey),
      const PerfilPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showFabLabel = false; // Ocultar etiqueta al cambiar de pestaña
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Recetas";
      case 1:
        return "Mi Despensa";
      case 2:
        return "Perfil";
      default:
        return "Savory";
    }
  }

  IconData _getFabIcon() {
    switch (_selectedIndex) {
      case 0:
        return Icons.add;
      case 1:
        return Icons.add_shopping_cart_outlined;
      case 2:
        return Icons.edit_outlined;
      default:
        return Icons.add;
    }
  }

  String _getFabLabel() {
    switch (_selectedIndex) {
      case 0:
        return "Agregar receta";
      case 1:
        return "Nuevo ingrediente";
      case 2:
        return "Editar perfil";
      default:
        return "Acción";
    }
  }

  void _onFabPressed() {
    switch (_selectedIndex) {
      case 0:
        // Llamar al método para agregar receta
        _recetasKey.currentState?.showAddRecipeDialog();
        break;
      case 1:
        // Llamar al método para agregar ingrediente
        _despensaKey.currentState?.showAddIngredientDialog();
        break;
      case 2:
        // Mostrar mensaje de función en desarrollo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Función de editar perfil en desarrollo'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeSavory = Color(0xFF47A72F);

    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 AppBar dinámico
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getAppBarTitle(),
              style: const TextStyle(
                color: verdeSavory,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined,
                  color: Colors.grey, size: 26),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificaciones en desarrollo'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // 🔹 Cuerpo principal
      body: Column(
        children: [
          // Campo de búsqueda visible solo en Recetas
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar receta...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implementar búsqueda de recetas
                },
              ),
            ),

          // Contenido principal
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),

      // 🔹 FAB con etiqueta dinámica
      floatingActionButton: GestureDetector(
        onLongPress: () {
          setState(() => _showFabLabel = !_showFabLabel);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Animación de texto lateral
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showFabLabel
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: verdeSavory.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getFabLabel(),
                        style: const TextStyle(
                          color: verdeSavory,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Botón principal
            FloatingActionButton(
              backgroundColor: verdeSavory,
              onPressed: _onFabPressed,
              child: Icon(_getFabIcon(), color: Colors.white),
            ),
          ],
        ),
      ),

      // 🔹 Barra inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: verdeSavory,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: 'Recetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            label: 'Despensa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}