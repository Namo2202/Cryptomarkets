import 'package:cryptoapi/SecondPage.dart';
import 'package:cryptoapi/StartButton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const ButtonSection(),
  ),
  GoRoute(
      path: '/fetcher/:currency',
      builder: ((context, state) => SecondPage(state.params['currency'])))
]);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: const MyHomePage(title: 'Flutter Layout Demo'),
    // );
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Image.asset(
//             "lib/10893838.png",
//             fit: BoxFit.fill,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//           Center(
//             child: ButtonSection(),
//           ),
//         ],
//       ),
//     );
//   }
// }
