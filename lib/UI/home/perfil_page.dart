import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_savory/UI/auth/login_page.dart';
import 'package:proyecto_savory/UI/app.dart';

class PerfilPage extends StatefulWidget {
  final ThemeProvider? themeProvider;

  const PerfilPage({super.key, this.themeProvider});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _modoOscuro = false;
  bool _notificaciones = false;

  @override
  void initState() {
    super.initState();
    _loadPreferencesAsync();
  }

  /// Carga preferencias de forma asíncrona sin bloquear la UI
  Future<void> _loadPreferencesAsync() async {
    if (_currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser.uid)
          .collection('preferencias')
          .doc('configuracion')
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _modoOscuro = doc.data()?['modo_oscuro'] ?? false;
          _notificaciones = doc.data()?['notificaciones'] ?? false;
        });

        // Aplicar modo oscuro al tema global si está disponible
        if (widget.themeProvider != null) {
          widget.themeProvider!.setDarkMode(_modoOscuro);
        }
      }
    } catch (e) {
      print('⚠️ Error cargando preferencias: $e');
    }
  }

  /// Construye todos los datos del perfil de forma asíncrona
  Future<Map<String, dynamic>> _buildProfileData() async {
    try {
      print('📋 Iniciando carga de datos del perfil...');
      
      final nombre = await _getNombreUsuario();
      print('✓ Nombre obtenido: $nombre');
      
      final username = await _getUsername();
      print('✓ Username obtenido: $username');
      
      final recetasCocinadas = await _getRecetasCocinadas();
      print('✓ Recetas cocinadas: $recetasCocinadas');
      
      final recetasGuardadas = await _getRecetasGuardadas();
      print('✓ Recetas favoritas obtenidas: ${recetasGuardadas.length}');

      return {
        'nombre': nombre,
        'username': username,
        'recetas_cocinadas': recetasCocinadas,
        'recetas_guardadas': recetasGuardadas,
      };
    } catch (e) {
      print('❌ Error construyendo datos de perfil: $e');
      return {
        'nombre': _currentUser?.displayName ?? 'Usuario',
        'username': 'usuario',
        'recetas_cocinadas': 0,
        'recetas_guardadas': [],
      };
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser.uid)
          .collection('preferencias')
          .doc('configuracion')
          .set({
        key: value,
      }, SetOptions(merge: true));
    } catch (e) {
      _showSnackBar('Error al guardar preferencia', Colors.redAccent);
    }
  }

  /// Obtiene el nombre del usuario
  Future<String> _getNombreUsuario() async {
    if (_currentUser == null) return 'Usuario';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser.uid)
          .get();

      return doc.data()?['nombre'] ?? _currentUser.displayName ?? 'Usuario';
    } catch (e) {
      return _currentUser.displayName ?? 'Usuario';
    }
  }

  /// Obtiene el username del usuario
  Future<String> _getUsername() async {
    if (_currentUser == null) return 'usuario';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser.uid)
          .get();

      return doc.data()?['username'] ?? 'usuario';
    } catch (e) {
      return 'usuario';
    }
  }

  /// Obtiene el total de recetas PREPARADAS (cocinadas)
  Future<int> _getRecetasCocinadas() async {
    if (_currentUser == null) {
      print('⚠️ Sin usuario para obtener recetas cocinadas');
      return 0;
    }

    try {
      print('🔍 Buscando recetas preparadas...');
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser.uid)
          .collection('recetas')
          .where('preparada', isEqualTo: true)
          .get();

      final count = snapshot.docs.length;
      print('✓ Recetas preparadas encontradas: $count');
      return count;
    } catch (e) {
      print('❌ Error obteniendo recetas preparadas: $e');
      return 0;
    }
  }

  /// Obtiene las recetas FAVORITAS del usuario desde Firestore
  Future<List<Map<String, dynamic>>> _getRecetasGuardadas() async {
    if (_currentUser == null) {
      print('⚠️ Sin usuario para obtener recetas favoritas');
      return [];
    }

    try {
      print('🔍 Buscando recetas favoritas...');
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser.uid)
          .collection('recetas')
          .where('favorita', isEqualTo: true)
          .limit(4) // Solo los primeros 4 para la UI
          .get();

      print('✓ Recetas favoritas encontradas: ${snapshot.docs.length}');

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'nombre': doc['titulo'] ?? 'Sin título',
                'imagen': doc['imagen_url'] ?? 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=400',
                'tiempo': '${doc['tiempo_preparacion'] ?? '?'} min',
              })
          .toList();
    } catch (e) {
      print('❌ Error obteniendo recetas favoritas: $e');
      return [];
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await FirebaseAuth.instance.signOut();
                
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                _showSnackBar(
                  'Error al cerrar sesión: ${e.toString()}',
                  Colors.redAccent,
                );
              }
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _buildProfileData(),
      builder: (context, snapshot) {
        // Mostrar loading mientras se cargan los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Perfil: Cargando datos...');
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF47A72F),
            ),
          );
        }

        // Manejo de errores
        if (snapshot.hasError) {
          print('❌ Error en FutureBuilder: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el perfil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data ?? {};
        final nombre = data['nombre'] ?? 'Usuario';
        final username = data['username'] ?? 'usuario';
        final recetasCocinadas = data['recetas_cocinadas'] ?? 0;
        final recetasGuardadas = data['recetas_guardadas'] ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),

            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF47A72F),
                    backgroundImage: _currentUser?.photoURL != null
                        ? NetworkImage(_currentUser!.photoURL!)
                        : null,
                    child: _currentUser?.photoURL == null
                        ? Text(
                            _getInitials(nombre),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '@$username',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Sección de Ajustes
            const Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF47A72F)),
                    title: const Text('Modo Oscuro'),
                    value: _modoOscuro,
                    activeColor: const Color(0xFF47A72F),
                    onChanged: (value) {
                      setState(() => _modoOscuro = value);
                      _savePreference('modo_oscuro', value);
                      
                      // Aplicar cambio de tema en tiempo real
                      if (widget.themeProvider != null) {
                        widget.themeProvider!.setDarkMode(value);
                      }
                      
                      _showSnackBar(
                        'Modo oscuro ${value ? 'activado' : 'desactivado'}',
                        const Color(0xFF47A72F),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined, color: Color(0xFF47A72F)),
                    title: const Text('Notificaciones'),
                    value: _notificaciones,
                    activeColor: const Color(0xFF47A72F),
                    onChanged: (value) {
                      setState(() => _notificaciones = value);
                      _savePreference('notificaciones', value);
                      _showSnackBar(
                        'Notificaciones ${value ? 'activadas' : 'desactivadas'}',
                        const Color(0xFF47A72F),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Mis Recetas Favoritas
            const Text(
              'Mis Recetas Favoritas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            if (recetasGuardadas.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay recetas favoritas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Marca tus recetas favoritas con el corazoncito',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recetasGuardadas.length,
                  itemBuilder: (context, index) {
                    final receta = recetasGuardadas[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              receta['imagen'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF47A72F),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Error cargando imagen: $error');
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.restaurant, size: 50),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receta['nombre'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        receta['tiempo'],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            // Estadísticas
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '$recetasCocinadas',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF47A72F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'recetas cocinadas con Savory!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Opciones
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: Color(0xFF47A72F)),
                    title: const Text('Editar perfil'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showSnackBar('Función en desarrollo', Colors.orange);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restaurant_menu_outlined, color: Color(0xFF47A72F)),
                    title: const Text('Mis preferencias'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showSnackBar('Función en desarrollo', Colors.orange);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: Color(0xFF47A72F)),
                    title: const Text('Configuración'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showSnackBar('Función en desarrollo', Colors.orange);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cerrar sesión
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: _logout,
              ),
            ),

            const SizedBox(height: 20),

            // Versión
            Center(
              child: Text(
                'Savory v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}