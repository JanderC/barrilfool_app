import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importa la función para inicializar localización
import 'package:barrilfood_app/providers/auth_provider.dart';
import 'package:barrilfood_app/providers/user_provider.dart'; // 👈 --- IMPORT USER_PROVIDER HERE ---
import 'package:barrilfood_app/providers/product_provider.dart';
import 'package:barrilfood_app/providers/category_provider.dart'; // 👈 --- IMPORT CATEGORY_PROVIDER HERE ---
import 'package:barrilfood_app/providers/cart_provider.dart'; // 👈 --- IMPORT CART_PROVIDER HERE ---
import 'package:barrilfood_app/screens/auth/login_screen.dart';
import 'package:barrilfood_app/screens/auth/splash_screen.dart';
import 'package:barrilfood_app/screens/client/client_home_screen.dart';
import 'package:barrilfood_app/screens/admin/admin_home_screen.dart';
import 'package:barrilfood_app/screens/employee/employee_home_screen.dart';
import 'package:barrilfood_app/providers/employee_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de Flutter
  await initializeDateFormatting('es', null); // Inicializa la localización para español

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()), // 👈 --- ADD USER_PROVIDER HERE ---
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // 👈 --- ADD CATEGORY_PROVIDER HERE ---
        ChangeNotifierProvider(create: (_) => CartProvider()), // 👈 --- ADD CART_PROVIDER HERE ---
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barrilfood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 7, 70, 245), // Color naranja para restaurante
          primary: const Color(0xFFFF8C00),
          secondary: const Color(0xFF4CAF50), // Verde para acentos
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isInitializing) {
            return const SplashScreen();
          }
          
          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }
          
          // Redirigir según el rol del usuario
          switch (authProvider.userRole) {
            case 1: // Administrador
              return const AdminHomeScreen();
            case 2: // Empleados
              return const EmployeeHomeScreen();
            case 3: // Repartidor
              return const EmployeeHomeScreen();
            case 4: // Cliente
            default:
              return const ClientHomeScreen();
          }
        },
      ),
    );
  }
}