import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
      ],
      child: const EcoHomeApp(),
    ),
  );
}

class EcoHomeApp extends StatelessWidget {
  const EcoHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHome Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary:   Color(0xFF2ECC71),
          surface:   Color(0xFF161B22),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const _Root(),
    );
  }
}

/// Decide si mostrar LoginScreen o HomeScreen según el estado de auth.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.unknown) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1117),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71))),
      );
    }

    if (auth.isAuthenticated) return const HomeScreen();
    return const LoginScreen();
  }
}
