// lib/UI/home/recetas_page.dart

import 'package:flutter/material.dart';
import '../../controllers/receta_controller.dart';
import '../../Models/receta_model.dart';

class RecetasPage extends StatefulWidget {
  const RecetasPage({super.key});

  @override
  State<RecetasPage> createState() => RecetasPageState();
}

class RecetasPageState extends State<RecetasPage> {
  final RecetaController _controller = RecetaController();
  bool _isGenerating = false;

  // Método público llamado desde Homepage
  void showAddRecipeDialog() {
    _showGenerateRecipesDialog();
  }

  Future<void> _showGenerateRecipesDialog() async {
    setState(() => _isGenerating = true);

    try {
      final ingredientes = await _controller.obtenerIngredientesDespensa();

      if (ingredientes.isEmpty) {
        setState(() => _isGenerating = false);
        if (!mounted) return;

        _showSnackBar(
          '⚠️ Debes agregar ingredientes a tu despensa primero',
          Colors.orange,
        );
        return;
      }

      final recetasGeneradas = await _controller.generarRecetasConIA();
      setState(() => _isGenerating = false);

      if (!mounted) return;

      _mostrarDialogoRecetasGeneradas(recetasGeneradas, ingredientes);
    } catch (e) {
      setState(() => _isGenerating = false);
      if (!mounted) return;

      _showSnackBar('Error: ${e.toString()}', Colors.redAccent);
    }
  }

  void _mostrarDialogoRecetasGeneradas(
    List<RecetaModel> recetas,
    List<IngredienteDespensaSimple> despensa,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Color(0xFF47A72F), size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Recetas Sugeridas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF47A72F),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 30),

              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recetas.length,
                  itemBuilder: (context, index) {
                    final receta = recetas[index];
                    final estadosIngredientes =
                        _controller.verificarEstadoIngredientes(receta, despensa);

                    return _buildRecetaCard(
                      receta,
                      estadosIngredientes,
                      context,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecetaCard(
    RecetaModel receta,
    List<IngredienteConEstado> estadosIngredientes,
    BuildContext context,
  ) {
    final disponibles = estadosIngredientes
        .where((i) => i.estado == EstadoIngrediente.disponible)
        .length;
    final total = estadosIngredientes.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _mostrarDetalleReceta(receta, estadosIngredientes),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la receta generada
              if (receta.imagenUrl.isNotEmpty)
                Container(
                  height: 150,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      receta.imagenUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF47A72F),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  height: 150,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF47A72F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(receta.categoria ?? 'Almuerzo'),
                      color: const Color(0xFF47A72F),
                      size: 50,
                    ),
                  ),
                ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF47A72F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(receta.categoria ?? 'Almuerzo'),
                      color: const Color(0xFF47A72F),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receta.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          receta.descripcion,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.timer_outlined,
                    '${receta.tiempoPreparacion} min',
                  ),
                  _buildDifficultyChip(receta.dificultad),
                  _buildIngredientesChip(disponibles, total),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF47A72F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _controller.guardarRecetaUsuario(receta);
                    _showSnackBar(
                      '✓ Receta guardada exitosamente',
                      const Color(0xFF47A72F),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Agregar a mis recetas',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleReceta(
    RecetaModel receta,
    List<IngredienteConEstado> estadosIngredientes,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 750),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen grande si existe
              if (receta.imagenUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Stack(
                      children: [
                        Image.network(
                          receta.imagenUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF47A72F),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade500,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF47A72F).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          _getCategoryIcon(receta.categoria ?? 'Almuerzo'),
                          size: 80,
                          color: const Color(0xFF47A72F),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF47A72F),
                ),
                child: Text(
                  receta.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receta.descripcion,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      _buildSeccionIngredientes(estadosIngredientes),
                      const SizedBox(height: 20),
                      _buildSeccionPasos(receta.pasos ?? []),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionIngredientes(
      List<IngredienteConEstado> estadosIngredientes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Ingredientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...estadosIngredientes.map((item) {
          Color color;
          IconData icon;

          switch (item.estado) {
            case EstadoIngrediente.disponible:
              color = Colors.green;
              icon = Icons.check_circle;
              break;
            case EstadoIngrediente.insuficiente:
              color = Colors.orange;
              icon = Icons.warning;
              break;
            case EstadoIngrediente.noDisponible:
              color = Colors.red;
              icon = Icons.cancel;
              break;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${item.ingrediente.nombre} - ${item.ingrediente.cantidad} ${item.ingrediente.unidad}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSeccionPasos(List<String> pasos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👨‍🍳 Preparación',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...pasos.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF47A72F),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String dificultad) {
    Color color = _getDifficultyColor(dificultad);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dificultad,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIngredientesChip(int disponibles, int total) {
    Color color = disponibles == total
        ? Colors.green
        : disponibles > total / 2
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_basket, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$disponibles/$total disponibles',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String dificultad) {
    switch (dificultad) {
      case 'Fácil':
        return Colors.green;
      case 'Media':
        return Colors.orange;
      case 'Difícil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Desayuno':
        return Icons.free_breakfast;
      case 'Almuerzo':
        return Icons.lunch_dining;
      case 'Cena':
        return Icons.dinner_dining;
      case 'Postre':
        return Icons.cake;
      case 'Snack':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.currentUser == null) {
      return const Center(child: Text('Por favor inicia sesión'));
    }

    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF47A72F)),
            SizedBox(height: 20),
            Text(
              '🤖 Generando recetas con IA...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF47A72F),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Esto puede tomar unos segundos',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<RecetaModel>>(
      stream: _controller.obtenerRecetasUsuario(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF47A72F)),
          );
        }

        final recetas = snapshot.data ?? [];

        if (recetas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: 100,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  'No tienes recetas guardadas',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Genera recetas con IA usando tus ingredientes',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF47A72F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: showAddRecipeDialog,
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text(
                    'Generar recetas con IA',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        // Grid de recetas guardadas - ARREGLADO
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6, // Cambiado a 0.6 para aún más altura
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: recetas.length,
          itemBuilder: (context, index) {
            final receta = recetas[index];

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () async {
                  final despensa =
                      await _controller.obtenerIngredientesDespensa();
                  final estados =
                      _controller.verificarEstadoIngredientes(receta, despensa);
                  if (!mounted) return;
                  _mostrarDetalleReceta(receta, estados);
                },
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Imagen/Icono superior
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: receta.imagenUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.network(
                              receta.imagenUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF47A72F),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              _getCategoryIcon(receta.categoria ?? 'Almuerzo'),
                              size: 50,
                              color: const Color(0xFF47A72F),
                            ),
                          ),
                  ),                    // Contenido - ARREGLADO
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10), // Reducido de 12 a 10
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título
                            Text(
                              receta.titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13, // Reducido de 14 a 13
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            
                            // Tiempo
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 13, // Reducido de 14 a 13
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${receta.tiempoPreparacion} min',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            
                            // Dificultad
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(receta.dificultad)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                receta.dificultad,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getDifficultyColor(receta.dificultad),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Acciones - ARREGLADO
                    Container(
                      height: 40, // Altura fija para los botones
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _controller.toggleFavorita(
                                receta.idReceta,
                                receta.favorita ?? false,
                              ),
                              child: Center(
                                child: Icon(
                                  (receta.favorita ?? false)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: (receta.favorita ?? false)
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar receta'),
                                    content: Text(
                                      '¿Estás seguro de eliminar "${receta.titulo}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _controller
                                              .eliminarRecetaUsuario(receta.idReceta);
                                          _showSnackBar(
                                            'Receta eliminada',
                                            const Color(0xFF47A72F),
                                          );
                                        },
                                        child: const Text(
                                          'Eliminar',
                                          style: TextStyle(color: Colors.redAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Center(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}