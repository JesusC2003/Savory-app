// lib/UI/home/recetas_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../controllers/receta_controller.dart';
import '../../controllers/receta_del_dia_controller.dart';
import '../../Models/receta_model.dart';

class RecetasPage extends StatefulWidget {
  const RecetasPage({super.key});

  @override
  State<RecetasPage> createState() => RecetasPageState();
}

class RecetasPageState extends State<RecetasPage> {
  final RecetaController _controller = RecetaController();
  final RecetaDelDiaController _recetaDelDiaController = RecetaDelDiaController();
  bool _isGenerating = false;
  
  // Variables para la receta del día (sin FutureBuilder)
  RecetaModel? _recetaDelDia;
  bool _cargandoRecetaDelDia = true;

  @override
  void initState() {
    super.initState();
    _cargarRecetaDelDia();
  }

  Future<void> _cargarRecetaDelDia() async {
    // Si ya está en caché, usar esa
    if (_recetaDelDiaController.tieneRecetaCargada) {
      setState(() {
        _recetaDelDia = _recetaDelDiaController.recetaActual;
        _cargandoRecetaDelDia = false;
      });
      return;
    }

    // Si no, cargar desde el servicio
    final receta = await _recetaDelDiaController.obtenerRecetaDelDia();
    if (mounted) {
      setState(() {
        _recetaDelDia = receta;
        _cargandoRecetaDelDia = false;
      });
    }
  }

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

  // ===== HELPER: Construir imagen (soporta base64 y URL) =====
  Widget _buildRecetaImage(String imagenUrl, {double height = 150, BorderRadius? borderRadius}) {
    final radius = borderRadius ?? BorderRadius.circular(10);
    
    if (imagenUrl.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF47A72F).withOpacity(0.1),
          borderRadius: radius,
        ),
        child: const Center(
          child: Icon(
            Icons.restaurant,
            color: Color(0xFF47A72F),
            size: 50,
          ),
        ),
      );
    }

    // Si es base64
    if (imagenUrl.startsWith('data:image')) {
      try {
        final base64Data = imagenUrl.split(',').last;
        return ClipRRect(
          borderRadius: radius,
          child: Image.memory(
            base64Decode(base64Data),
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: radius,
                ),
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          ),
        );
      } catch (e) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: radius,
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      }
    }

    // Si es URL normal
    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imagenUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF47A72F)),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: radius,
            ),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
        },
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
              Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildRecetaImage(receta.imagenUrl, height: 150),
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
              // Imagen grande
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      _buildRecetaImage(
                        receta.imagenUrl,
                        height: 200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
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
              ),
              Container(
                width: double.infinity,
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
        }),
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
        }),
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
        final recetasPreparadas =
            recetas.where((r) => r.preparada == true).toList();

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

        // ===== LAYOUT PRINCIPAL =====
        return SingleChildScrollView(
          child: Column(
            children: [
              // ===== RECETA DEL DÍA (SIN FUTUREBUILDER) =====
              if (_cargandoRecetaDelDia)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⭐ Receta del Día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF47A72F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF47A72F),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_recetaDelDia != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⭐ Receta del Día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF47A72F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRecetaDelDiaCard(_recetaDelDia!),
                    ],
                  ),
                ),

              const Divider(height: 30, indent: 16, endIndent: 16),

              // ===== RECETAS PREPARADAS (CARRUSEL) =====
              if (recetasPreparadas.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Recetas Preparadas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF47A72F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recetasPreparadas.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildRecetaCarrouselCard(
                                recetasPreparadas[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

              // ===== RECETAS GUARDADAS (CARRUSEL) =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📚 Mis Recetas Guardadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF47A72F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recetas.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildRecetaCarrouselCard(recetas[index]),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Botón para generar nuevas recetas
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF47A72F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: showAddRecipeDialog,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text(
                      'Generar nuevas recetas',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== WIDGET: RECETA DEL DÍA =====
  Widget _buildRecetaDelDiaCard(RecetaModel receta) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () async {
          final despensa = await _controller.obtenerIngredientesDespensa();
          final estados = _controller.verificarEstadoIngredientes(receta, despensa);
          if (!mounted) return;
          _mostrarDetalleReceta(receta, estados);
        },
        borderRadius: BorderRadius.circular(15),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: SizedBox(
                width: 150,
                height: 200,
                child: _buildRecetaImage(
                  receta.imagenUrl,
                  height: 200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receta.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receta.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${receta.tiempoPreparacion} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET: RECETA EN CARRUSEL =====
  Widget _buildRecetaCarrouselCard(RecetaModel receta) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () async {
            final despensa = await _controller.obtenerIngredientesDespensa();
            final estados = _controller.verificarEstadoIngredientes(receta, despensa);
            if (!mounted) return;
            _mostrarDetalleReceta(receta, estados);
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: _buildRecetaImage(
                    receta.imagenUrl,
                    height: 110,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              // Contenido
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        receta.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${receta.tiempoPreparacion}m',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Acciones
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => _controller.toggleFavorita(
                        receta.idReceta,
                        receta.favorita ?? false,
                      ),
                      child: Icon(
                        (receta.favorita ?? false)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: (receta.favorita ?? false)
                            ? Colors.red
                            : Colors.grey,
                        size: 16,
                      ),
                    ),
                    InkWell(
                      onTap: () => _controller.togglePreparada(
                        receta.idReceta,
                        receta.preparada ?? false,
                      ),
                      child: Icon(
                        (receta.preparada ?? false)
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: (receta.preparada ?? false)
                            ? const Color(0xFF47A72F)
                            : Colors.grey,
                        size: 16,
                      ),
                    ),
                    InkWell(
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
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
