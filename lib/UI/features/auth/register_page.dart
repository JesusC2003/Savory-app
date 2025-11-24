import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_savory/UI/features/auth/login_page.dart';
import 'package:proyecto_savory/UI/features/Homepage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _aceptarTerminos = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Variables para validación en tiempo real
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validación de nombre en tiempo real
  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = null;
      } else if (value.length < 3) {
        _nameError = 'Mínimo 3 caracteres';
      } else if (value.length > 50) {
        _nameError = 'Máximo 50 caracteres';
      } else if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
        _nameError = 'Solo letras y espacios';
      } else {
        _nameError = null;
      }
    });
  }

  // Validación de email en tiempo real
  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
      } else if (!_isValidEmail(value)) {
        _emailError = 'Correo inválido';
      } else {
        _emailError = null;
      }
    });
  }

  // Validación de contraseña en tiempo real
  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = null;
      } else if (value.length < 6) {
        _passwordError = 'Mínimo 6 caracteres';
      } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
        _passwordError = 'Debe tener mayúsculas y minúsculas';
      } else if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
        _passwordError = 'Debe incluir al menos un número';
      } else {
        _passwordError = null;
      }
    });

    // Re-validar confirmación si ya tiene texto
    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword(_confirmPasswordController.text);
    }
  }

  // Validación de confirmación de contraseña
  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = null;
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Las contraseñas no coinciden';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar términos
    if (!_aceptarTerminos) {
      _showSnackBar(
        'Debes aceptar los términos y condiciones',
        Colors.redAccent,
      );
      return;
    }

    // Validar que no haya errores
    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      _showSnackBar(
        'Por favor corrige los errores antes de continuar',
        Colors.redAccent,
      );
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      setState(() => _loading = true);

      // Crear usuario en Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar nombre de usuario
      await userCredential.user?.updateDisplayName(name);

      // Guardar datos adicionales en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'id_usuario': userCredential.user!.uid,
        'nombre': name,
        'correo': email,
        'tipo_cuenta': 'gratuita',
        'preferencias_dieta': [],
        'fecha_registro': DateTime.now().toIso8601String(),
        'ultimo_acceso': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        _showSnackBar(
          '¡Cuenta creada exitosamente! Bienvenido a Savory',
          const Color(0xFF47A72F),
        );

        // Navegar al home
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al crear la cuenta";

      switch (e.code) {
        case 'weak-password':
          mensaje = "La contraseña es muy débil";
          break;
        case 'email-already-in-use':
          mensaje = "Ya existe una cuenta con este correo";
          break;
        case 'invalid-email':
          mensaje = "Formato de correo inválido";
          break;
        case 'operation-not-allowed':
          mensaje = "Registro no permitido. Contacta soporte";
          break;
        case 'network-request-failed':
          mensaje = "Sin conexión a internet";
          break;
        default:
          mensaje = "Error: ${e.message}";
      }

      if (mounted) {
        _showSnackBar(mensaje, Colors.redAccent);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          "Error inesperado: ${e.toString()}",
          Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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

  void _showTermsDialog() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Botón de volver atrás (estilo moderno)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF47A72F)),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),

                const SizedBox(height: 10),

                // Logo y título
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 90),
                      const SizedBox(height: 10),
                      const Text(
                        'Regístrate en Savory',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF47A72F),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Crea tu cuenta y comienza a cocinar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Campo de nombre
                TextFormField(
                  controller: _nameController,
                  onChanged: _validateName,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Juan Pérez',
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: _nameError,
                    suffixIcon: _nameController.text.isNotEmpty
                        ? Icon(
                            _nameError == null
                                ? Icons.check_circle
                                : Icons.error,
                            color: _nameError == null
                                ? Colors.green
                                : Colors.red,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF47A72F),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailError,
                    suffixIcon: _emailController.text.isNotEmpty
                        ? Icon(
                            _emailError == null
                                ? Icons.check_circle
                                : Icons.error,
                            color: _emailError == null
                                ? Colors.green
                                : Colors.red,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF47A72F),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    if (!_isValidEmail(value)) {
                      return 'Correo electrónico inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _passwordError,
                    helperText: 'Debe incluir mayúsculas, minúsculas y números',
                    helperStyle: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF47A72F),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Campo de confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onChanged: _validateConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    hintText: 'Repite tu contraseña',
                    prefixIcon: const Icon(Icons.lock_person_outlined),
                    errorText: _confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF47A72F),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Checkbox términos y condiciones
                Row(
                  children: [
                    Checkbox(
                      value: _aceptarTerminos,
                      activeColor: const Color(0xFF47A72F),
                      onChanged: (value) {
                        setState(() {
                          _aceptarTerminos = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text("He leído y acepto los "),
                          GestureDetector(
                            onTap: _showTermsDialog,
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

                // Botón de crear cuenta
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF47A72F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 2,
                  ),
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 25),

                // Ir al login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿Ya tienes una cuenta? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Inicia sesión",
                        style: TextStyle(
                          color: Color(0xFF47A72F),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}