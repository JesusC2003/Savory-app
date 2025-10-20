import 'package:flutter/material.dart';

// 🌿 Pantalla de Inicio de Sesión (LoginPage)
// Forma parte del módulo de autenticación de Savory.
// Permite ingresar con correo y contraseña o usar el inicio de sesión con Google.
//
// Diseño basado en el color verde #47A72F (verde Savory)
// Autor: Jesús Castillo

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF47A72F),
        title: const Text("Iniciar sesión"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            // Logo de la aplicación
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bienvenido a Savory',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Campo de correo electrónico
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Campo de contraseña
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Enlace "¿Olvidaste tu contraseña?"
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                },
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: const Color(0xFF47A72F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Botón principal: Iniciar sesión
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF47A72F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // TODO: Conectar con Firebase Auth (signInWithEmailAndPassword)
              },
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Enlace hacia la pantalla de registro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿No tienes una cuenta? "),
                GestureDetector(
                  onTap: () {
                    // Navegar a la pantalla de registro
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: Text(
                    "Crea una",
                    style: TextStyle(
                      color: const Color(0xFF47A72F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Línea divisoria con texto "O continúa con"
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("O continúa con"),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),

            const SizedBox(height: 25),

            // Botón de inicio con Google
            OutlinedButton.icon(
              icon: Image.asset(
                'assets/google.png',
                height: 22,
              ),
              label: const Text(
                'Iniciar con Google',
                style: TextStyle(fontSize: 15),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
      
              },
            ),

            const SizedBox(height: 30),

            
          ],
        ),
      ),
    );
  }
}
