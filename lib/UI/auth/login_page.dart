import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_savory/UI/home/Homepage.dart';
import 'package:proyecto_savory/UI/auth/register_page.dart';
import 'package:proyecto_savory/UI/auth/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _obscurePassword = true;
  
  // Variables para validación en tiempo real
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      } else {
        _passwordError = null;
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _login() async {
    // Validar campos antes de continuar
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(
        "Por favor completa todos los campos",
        Colors.redAccent,
      );
      return;
    }

    if (_emailError != null || _passwordError != null) {
      _showSnackBar(
        "Corrige los errores antes de continuar",
        Colors.redAccent,
      );
      return;
    }

    try {
      setState(() => _loading = true);
      
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al iniciar sesión";
      
      switch (e.code) {
        case 'user-not-found':
          mensaje = "No existe una cuenta con este correo";
          break;
        case 'wrong-password':
          mensaje = "Contraseña incorrecta";
          break;
        case 'invalid-email':
          mensaje = "Formato de correo inválido";
          break;
        case 'user-disabled':
          mensaje = "Esta cuenta ha sido deshabilitada";
          break;
        case 'too-many-requests':
          mensaje = "Demasiados intentos. Intenta más tarde";
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

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _loadingGoogle = true);

      // Iniciar el proceso de autenticación con Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        if (mounted) {
          setState(() => _loadingGoogle = false);
        }
        return;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear credenciales
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase
      UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Verificar si es un nuevo usuario y guardar en Firestore
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
          'id_usuario': userCredential.user!.uid,
          'nombre': userCredential.user!.displayName ?? 'Usuario',
          'correo': userCredential.user!.email ?? '',
          'tipo_cuenta': 'gratuita',
          'preferencias_dieta': [],
          'fecha_registro': DateTime.now().toIso8601String(),
          'ultimo_acceso': DateTime.now().toIso8601String(),
        });
      } else {
        // Actualizar último acceso
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .update({
          'ultimo_acceso': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al iniciar sesión con Google";

      switch (e.code) {
        case 'account-exists-with-different-credential':
          mensaje = "Ya existe una cuenta con este correo usando otro método";
          break;
        case 'invalid-credential':
          mensaje = "Credenciales inválidas";
          break;
        case 'operation-not-allowed':
          mensaje = "Inicio de sesión con Google no permitido";
          break;
        case 'user-disabled':
          mensaje = "Esta cuenta ha sido deshabilitada";
          break;
        case 'user-not-found':
          mensaje = "No se encontró el usuario";
          break;
        case 'wrong-password':
          mensaje = "Contraseña incorrecta";
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
        setState(() => _loadingGoogle = false);
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
                const SizedBox(height: 15),
                
                // Logo y título
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: 120),
                      const SizedBox(height: 10),
                      const Text(
                        'Bienvenido a Savory',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF47A72F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión para continuar',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // Campo de correo con validación
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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

                // Campo de contraseña con validación
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: _passwordError,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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

                const SizedBox(height: 10),

                // Olvidaste tu contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Color(0xFF47A72F),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Botón de iniciar sesión
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF47A72F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // Ir al registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿No tienes una cuenta? ",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Regístrate",
                        style: TextStyle(
                          color: Color(0xFF47A72F),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Divisor "o"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Botón de Google
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: _loadingGoogle ? null : _signInWithGoogle,
                  icon: _loadingGoogle
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFF47A72F),
                            strokeWidth: 2,
                          ),
                        )
                      : Image.asset(
                          'assets/google.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.login,
                              color: Color(0xFF47A72F),
                            );
                          },
                        ),
                  label: Text(
                    'Continuar con Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

                const SizedBox(height: 30),               
              ],
            ),
          ),
        ),
      ),
    );
  }
}