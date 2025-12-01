import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proyecto_savory/services/ocr.service.dart';
import 'package:proyecto_savory/controllers/despensa_controller.dart';
import 'widgets/despensa_empty_state.dart';
import 'widgets/despensa_item_card.dart';
import 'widgets/add_ingredient_options_sheet.dart';
import 'widgets/add_ingredient_manual_dialog.dart';
import 'constants/despensa_constants.dart';

class DespensaPage extends StatefulWidget {
  const DespensaPage({super.key});

  @override
  State<DespensaPage> createState() => DespensaPageState();
}

class DespensaPageState extends State<DespensaPage> {
  final DespensaController _controller = DespensaController();
  final OcrService _ocrService = OcrService();

  // Método público para Homepage
  void showAddIngredientDialog() {
    _mostrarOpcionesAgregar();
  }

  // ==========================================
  // MÉTODOS DE NAVEGACIÓN Y DIÁLOGOS
  // ==========================================

  void _mostrarOpcionesAgregar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddIngredientOptionsSheet(
        onTomarFoto: _escanearConCamara,
        onSubirImagen: _escanearDesdeGaleria,
        onAgregarManual: _mostrarDialogoManual,
      ),
    );
  }

  void _mostrarDialogoManual({
    String? docId,
    String? nombre,
    String? cantidad,
    String? unidad,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddIngredientManualDialog(
        nombreInicial: nombre,
        cantidadInicial: cantidad,
        unidadInicial: unidad,
        isEditing: docId != null,
        onGuardar: (nombre, cantidad, unidad) async {
          try {
            if (docId != null) {
              await _controller.actualizarIngrediente(
                docId: docId,
                nombre: nombre,
                cantidad: cantidad,
                unidad: unidad,
              );
              _showSnackBar(
                'Ingrediente actualizado',
                DespensaConstants.verdeSavory,
              );
            } else {
              await _controller.agregarIngrediente(
                nombre: nombre,
                cantidad: cantidad,
                unidad: unidad,
              );
              _showSnackBar(
                'Ingrediente agregado exitosamente',
                DespensaConstants.verdeSavory,
              );
            }
          } catch (e) {
            _showSnackBar(
              'Error: ${e.toString()}',
              DespensaConstants.rojoError,
            );
          }
        },
      ),
    );
  }

  void _mostrarDialogoEliminar(String docId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar ingrediente'),
        content: Text('¿Estás seguro de eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DespensaConstants.rojoError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _controller.eliminarIngrediente(docId);
                _showSnackBar(
                  'Ingrediente eliminado',
                  DespensaConstants.verdeSavory,
                );
              } catch (e) {
                _showSnackBar(
                  'Error al eliminar: ${e.toString()}',
                  DespensaConstants.rojoError,
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MÉTODOS OCR - ACTUALIZADOS PARA ALIBABA
  // ==========================================

  Future<void> _escanearConCamara() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        _mostrarDialogoPermisos();
      } else {
        _showSnackBar(
          '⚠️ Permisos de cámara requeridos',
          DespensaConstants.naranjaWarning,
        );
      }
      return;
    }

    await _procesarOCR(() => _ocrService.escanearDesdeCamara());
  }

  Future<void> _escanearDesdeGaleria() async {
    await _procesarOCR(() => _ocrService.escanearDesdeGaleria());
  }

  Future<void> _procesarOCR(Future<List<Map<String, String>>> Function() ocrFunction) async {
    try {
      _showLoadingDialog(DespensaConstants.mensajeProcesandoImagen);

      final ingredientes = await ocrFunction();

      if (!mounted) return;
      Navigator.pop(context);

      if (ingredientes.isEmpty) {
        _showSnackBar(
          'No se detectaron ingredientes. Intenta de nuevo',
          DespensaConstants.naranjaWarning,
        );
        return;
      }

      _mostrarDialogoIngredientesDetectados(ingredientes);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar(
        'Error: ${e.toString()}',
        DespensaConstants.rojoError,
      );
    }
  }

  void _mostrarDialogoIngredientesDetectados(List<Map<String, String>> ingredientes) {
    showDialog(
      context: context,
      builder: (context) => IngredientesDetectadosDialogEnhanced(
        ingredientes: ingredientes,
        onAgregarSeleccionados: (seleccionados) async {
          await _agregarIngredientesLote(seleccionados);
        },
      ),
    );
  }

  Future<void> _agregarIngredientesLote(List<Map<String, String>> ingredientes) async {
    if (ingredientes.isEmpty) return;

    try {
      _showLoadingDialog(DespensaConstants.mensajeAgregandoIngredientes);

      await _controller.agregarIngredientesLote(ingredientes);

      if (!mounted) return;
      Navigator.pop(context);

      final cantidad = ingredientes.length;
      _showSnackBar(
        '✓ $cantidad ingrediente${cantidad != 1 ? 's' : ''} agregado${cantidad != 1 ? 's' : ''}',
        DespensaConstants.verdeSavory,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar(
        'Error: ${e.toString()}',
        DespensaConstants.rojoError,
      );
    }
  }

  // ==========================================
  // UTILIDADES
  // ==========================================

  void _mostrarDialogoPermisos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Permisos requeridos'),
        content: const Text(
          'La aplicación necesita acceso a la cámara para escanear ingredientes. '
          '¿Deseas abrir la configuración?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DespensaConstants.verdeSavory,
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'Abrir configuración',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: DespensaConstants.verdeSavory,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    mensaje,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    if (_controller.currentUser == null) {
      return const Center(
        child: Text(
          'Por favor inicia sesión',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _controller.obtenerIngredientes(),
      builder: (context, snapshot) {
        // Estado de error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: DespensaConstants.rojoError,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar ingredientes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: DespensaConstants.verdeSavory,
            ),
          );
        }

        final items = snapshot.data?.docs ?? [];

        // Estado vacío
        if (items.isEmpty) {
          return DespensaEmptyState(
            onAgregarPressed: showAddIngredientDialog,
          );
        }

        // Lista de ingredientes
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final doc = items[index];
            final data = doc.data() as Map<String, dynamic>;

            return DespensaItemCard(
              nombre: data['nombre'] ?? 'Sin nombre',
              cantidad: data['cantidad'] ?? '0',
              unidad: data['unidad'] ?? 'unidades',
              onEdit: () => _mostrarDialogoManual(
                docId: doc.id,
                nombre: data['nombre'],
                cantidad: data['cantidad'],
                unidad: data['unidad'],
              ),
              onDelete: () => _mostrarDialogoEliminar(
                doc.id,
                data['nombre'] ?? 'Sin nombre',
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}

// ==========================================
// DIÁLOGO MEJORADO PARA INGREDIENTES DETECTADOS
// ==========================================

class IngredientesDetectadosDialogEnhanced extends StatefulWidget {
  final List<Map<String, String>> ingredientes;
  final Future<void> Function(List<Map<String, String>>) onAgregarSeleccionados;

  const IngredientesDetectadosDialogEnhanced({
    super.key,
    required this.ingredientes,
    required this.onAgregarSeleccionados,
  });

  @override
  State<IngredientesDetectadosDialogEnhanced> createState() =>
      _IngredientesDetectadosDialogEnhancedState();
}

class _IngredientesDetectadosDialogEnhancedState
    extends State<IngredientesDetectadosDialogEnhanced> {
  late List<bool> seleccionados;

  @override
  void initState() {
    super.initState();
    seleccionados = List.filled(widget.ingredientes.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final cantidadSeleccionada = seleccionados.where((s) => s).length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: DespensaConstants.verdeSavory,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Ingredientes detectados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$cantidadSeleccionada de ${widget.ingredientes.length} seleccionados',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.ingredientes.length,
          itemBuilder: (context, index) {
            final ing = widget.ingredientes[index];
            return CheckboxListTile(
              value: seleccionados[index],
              onChanged: (value) {
                setState(() {
                  seleccionados[index] = value ?? false;
                });
              },
              title: Text(
                ing['nombre'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${ing['cantidad']} ${ing['unidad']}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              activeColor: DespensaConstants.verdeSavory,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DespensaConstants.verdeSavory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: cantidadSeleccionada > 0
              ? () {
                  final ingredientesSeleccionados = <Map<String, String>>[];
                  for (int i = 0; i < widget.ingredientes.length; i++) {
                    if (seleccionados[i]) {
                      ingredientesSeleccionados.add(widget.ingredientes[i]);
                    }
                  }
                  Navigator.pop(context);
                  widget.onAgregarSeleccionados(ingredientesSeleccionados);
                }
              : null,
          child: Text(
            'Agregar ($cantidadSeleccionada)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}