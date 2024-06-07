import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hexagonui/pages/atec/atec.dart';
import 'package:hexagonui/pages/clientDetail/client_detail.dart';
import 'package:hexagonui/pages/home/home.dart';
import 'package:hexagonui/pages/login/login.dart';

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/atec/:id',
      name: 'atec',
      builder: (context, state) {
        final userId = state.pathParameters['id'] ?? '0';
        return Atec(client: userId);
      },
    ),
    GoRoute(
        path: '/detailclient/:id/:name', // Replace with your actual path
        name: 'detailclient',
        builder: (context, state) {
          final userId =
              state.pathParameters['id'] ?? '0'; // Providing a default value
          final userName =
              state.pathParameters['name'] ?? ''; // Providing a default value

          return ClientDetail(
            id: userId,
            name: userName,
          );
        }),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(
        //     seedColor: Colors.lightBlue,
        //     background: Color(0xFF1E1E1E),
        //   ),
        //   useMaterial3: true,
        //   drawerTheme: DrawerThemeData(
        //     backgroundColor: Color(0xFF070707), // Cor de fundo do Drawer
        //   ),
        //   listTileTheme: ListTileThemeData(textColor: Colors.white),
        //   //iconTheme: IconThemeData(color: Colors.white),
        //   //iconButtonTheme: IconButtonThemeData(),
        //   //
        //   //
        //   //primaryIconTheme: IconThemeData(color: Colors.white),
        //   textTheme: const TextTheme(
        //     bodyLarge:
        //         TextStyle(color: Colors.white), // Cor do texto para bodyText1
        //     bodyMedium: TextStyle(color: Color()),
        //     bodySmall: TextStyle(color: Colors.white),
        //   ),
        // ),
        theme: ThemeData(
          brightness: Brightness.dark, // Define o tema como escuro
          primaryColor: Colors.lightBlue,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F1F1F),
            foregroundColor: Colors.white,
          ),
          drawerTheme: const DrawerThemeData(
            backgroundColor: Color(0xFF1F1F1F),
            elevation: 16,
          ),
          cardColor: const Color(0xFF1F1F1F),
          // textTheme: const TextTheme(
          //   bodyText1: TextStyle(color: Colors.white),
          //   bodyText2: TextStyle(color: Colors.white70),
          //   headline1: TextStyle(color: Colors.white),
          //   headline2: TextStyle(color: Colors.white),
          //   headline3: TextStyle(color: Colors.white),
          //   headline4: TextStyle(color: Colors.white),
          //   headline5: TextStyle(color: Colors.white),
          //   headline6: TextStyle(color: Colors.white),
          // ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF303030),
            // enabledBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: Colors.red),
            // ),
            focusedBorder: OutlineInputBorder(
                //borderSide: BorderSide(color: Colors.lightBlue, width: 1.0),
                ),
            //labelStyle: TextStyle(color: Colors.green),
            hintStyle: TextStyle(color: Colors.white),
          ),
          buttonTheme: const ButtonThemeData(
            buttonColor: Colors.lightBlue,
            textTheme: ButtonTextTheme.primary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.lightBlue,
          ),
          checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateProperty.all(Colors.white),
            fillColor: MaterialStateProperty.all(Colors.lightBlue),
          ),
        ),
        routerConfig: _router);
  }
}
