import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/pokemon_viewmodel.dart';
import 'views/home_page.dart';
import 'views/explore_page.dart';
import 'views/search_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PokemonViewModel()),
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
      title: 'PokéDex TCG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/explore': (context) => const ExplorePage(),
        '/search': (context) => const SearchPage(),
      },
    );
  }
}
