import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool aceptarTerminos = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear cuenta"),
        centerTitle: true,
        backgroundColor: const Color(0xFF47A72F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

          
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 90,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Regístrate en Savory',
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
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            
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

            const SizedBox(height: 20),

          
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.lock_person_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            
            Row(
              children: [
                Checkbox(
                  value: aceptarTerminos,
                  activeColor: const Color(0xFF47A72F),
                  onChanged: (value) {
                    setState(() {
                      aceptarTerminos = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      const Text("He leído y acepto los "),
                      GestureDetector(
                        onTap: () {
                         
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Términos y Condiciones"),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Bienvenido a Savory 🍃\n\n"
                                      "Al registrarte en nuestra aplicación, aceptas los siguientes términos:",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "1️⃣ Uso del servicio\n"
                                      "Savory permite gestionar tu despensa, crear listas de compras y descubrir recetas. "
                                      "Te comprometes a usar la app de forma responsable y no compartir información falsa.",
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "2️⃣ Privacidad\n"
                                      "Tus datos personales (como nombre y correo electrónico) se almacenan de forma segura mediante Firebase Auth. "
                                      "Savory no comparte información con terceros sin tu consentimiento.",
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "3️⃣ Contenido generado por IA\n"
                                      "Las recetas sugeridas por la inteligencia artificial son generadas automáticamente. "
                                      "Savory no se responsabiliza por errores o resultados no deseados en dichas recetas.",
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "4️⃣ Suscripciones y acceso Premium\n"
                                      "Al adquirir una suscripción, obtendrás acceso a contenido exclusivo. "
                                      "Los pagos se gestionan mediante las plataformas oficiales (Google Play / App Store).",
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "5️⃣ Limitación de responsabilidad\n"
                                      "Savory no se hace responsable de daños ocasionados por el mal uso de la app o sus recomendaciones alimenticias.",
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "6️⃣ Modificaciones\n"
                                      "Estos términos pueden actualizarse en cualquier momento. "
                                      "Te notificaremos dentro de la app cuando existan cambios relevantes.",
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Al continuar, confirmas que has leído y aceptado estos términos.",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text(
                                    "Cerrar",
                                    style: TextStyle(color: Color(0xFF47A72F)),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          "términos y condiciones",
                          style: TextStyle(
                            color: Color(0xFF47A72F),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

        
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF47A72F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                if (!aceptarTerminos) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Debes aceptar los términos y condiciones.'),
                    ),
                  );
                  return;
                }
              },
              child: const Text(
                'Crear cuenta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25),

     
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿Ya tienes una cuenta? "),
                GestureDetector(
                  onTap: () {
                
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Inicia sesión",
                    style: TextStyle(
                      color: Color(0xFF47A72F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
