import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_savory/UI/auth/login_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _modoOscuro = false;
  bool _notificaciones = false;
  int _recetasCocinadas = 42;
  
  // Lista de recetas guardadas de ejemplo
  final List<Map<String, dynamic>> _recetasGuardadas = [
    {
      'nombre': 'Curry de Garbanzos y Espinacas',
      'imagen': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
      'tiempo': '45 min',
    },
    {
      'nombre': 'Tacos de Lentejas Picantes',
      'imagen': 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=400',
      'tiempo': '30 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPreferences();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _recetasCocinadas = _userData?['recetas_cocinadas'] ?? 42;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Error al cargar datos: ${e.toString()}', Colors.redAccent);
    }
  }

  Future<void> _loadPreferences() async {
    if (_currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .collection('preferencias')
          .doc('configuracion')
          .get();

      if (doc.exists) {
        setState(() {
          _modoOscuro = doc.data()?['modo_oscuro'] ?? false;
          _notificaciones = doc.data()?['notificaciones'] ?? false;
        });
      }
    } catch (e) {
      // Error silencioso para preferencias
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .collection('preferencias')
          .doc('configuracion')
          .set({
        key: value,
      }, SetOptions(merge: true));
    } catch (e) {
      _showSnackBar('Error al guardar preferencia', Colors.redAccent);
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
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF47A72F),
        ),
      );
    }

    final nombre = _userData?['nombre'] ?? _currentUser?.displayName ?? 'Usuario';
    final correo = _userData?['correo'] ?? _currentUser?.email ?? 'Sin correo';
    final username = _userData?['username'] ?? 'usuario';

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

        // Mis Recetas Guardadas
        const Text(
          'Mis Recetas Guardadas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recetasGuardadas.length,
            itemBuilder: (context, index) {
              final receta = _recetasGuardadas[index];
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
                        errorBuilder: (context, error, stackTrace) {
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
                  '$_recetasCocinadas',
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

        // Opciones (manteniendo las existentes)
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
  }
}