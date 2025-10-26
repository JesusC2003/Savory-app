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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    final tipoCuenta = _userData?['tipo_cuenta'] ?? 'gratuita';
    final fechaRegistro = _userData?['fecha_registro'];

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
                child: _currentUser?.photoURL != null
                    ? ClipOval(
                        child: Image.network(
                          _currentUser!.photoURL!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              _getInitials(nombre),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        _getInitials(nombre),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 15),
              Text(
                nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF47A72F),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: tipoCuenta == 'premium'
                      ? Colors.amber.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tipoCuenta == 'premium' ? '👑 Premium' : '🆓 Gratuita',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tipoCuenta == 'premium'
                        ? Colors.amber.shade900
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Información del usuario
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Color(0xFF47A72F)),
                title: const Text('Correo electrónico'),
                subtitle: Text(correo),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF47A72F)),
                title: const Text('Miembro desde'),
                subtitle: Text(
                  fechaRegistro != null
                      ? _formatDate(fechaRegistro)
                      : 'No disponible',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

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
                  // TODO: Implementar edición de perfil
                  _showSnackBar('Función en desarrollo', Colors.orange);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restaurant_menu_outlined, color: Color(0xFF47A72F)),
                title: const Text('Mis preferencias'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implementar preferencias
                  _showSnackBar('Función en desarrollo', Colors.orange);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Color(0xFF47A72F)),
                title: const Text('Configuración'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implementar configuración
                  _showSnackBar('Función en desarrollo', Colors.orange);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Upgrade a Premium (si es gratuita)
        if (tipoCuenta != 'premium')
          Card(
            elevation: 2,
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text(
                'Upgrade a Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Desbloquea todas las funciones'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Implementar upgrade
                _showSnackBar('Función en desarrollo', Colors.orange);
              },
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}