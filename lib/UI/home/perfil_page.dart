import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF47A72F),
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 15),
        const Text(
          "SAVORY",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        const ListTile(
          leading: Icon(Icons.email_outlined, color: Color(0xFF47A72F)),
          title: Text("Correo"),
          subtitle: Text("admin@savory.com"),
        ),
        const ListTile(
          leading: Icon(Icons.settings_outlined, color: Color(0xFF47A72F)),
          title: Text("Configuración"),
        ),
        const ListTile(
          leading: Icon(Icons.logout, color: Colors.redAccent),
          title: Text("Cerrar sesión"),
        ),
      ],
    );
  }
}
