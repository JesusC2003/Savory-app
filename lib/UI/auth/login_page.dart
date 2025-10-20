import 'package:flutter/material.dart';
import 'package:proyecto_savory/UI/home/Homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  final String _defaultEmail = 'admin@savory.com';
  final String _defaultPassword = '123456';

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == _defaultEmail && password == _defaultPassword) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo o contraseña incorrectos'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

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


            TextField(
              controller: _emailController,
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


            TextField(
              controller: _passwordController,
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

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: Color(0xFF47A72F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF47A72F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _login, 
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿No tienes una cuenta? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    "Crea una",
                    style: TextStyle(
                      color: Color(0xFF47A72F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

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
              onPressed: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
