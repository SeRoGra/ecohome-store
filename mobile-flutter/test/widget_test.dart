import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecohome_flutter/main.dart';
import 'package:ecohome_flutter/providers/auth_provider.dart';
import 'package:ecohome_flutter/providers/products_provider.dart';

void main() {
  testWidgets('EcoHomeApp muestra LoginScreen al iniciar sin sesión', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ],
        child: const EcoHomeApp(),
      ),
    );

    // Espera a que el estado de auth se resuelva
    await tester.pumpAndSettle();

    // Sin sesión guardada debe mostrar el campo de usuario
    expect(find.text('EcoHome Store'), findsOneWidget);
  });
}
