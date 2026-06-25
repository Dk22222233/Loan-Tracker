import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:qarazdare/providers/notifier.dart';

import 'package:qarazdare/screens/maininterface.dart';
import 'package:qarazdare/screens/statitics.dart';
import 'package:qarazdare/screens/form.dart';
//import 'package:qarazdare/screens/chart_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final navigationProvider = StateProvider<int>((ref) => 0);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyApp();
}

class _MyApp extends ConsumerState<MyApp> {
  List<Widget> pages = [Maininterface(), ChartScreen()];
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.person_2), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.donut_large), label: 'Statistics')
  ];
  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navigationProvider);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 67, 255, 77),
                    Color.fromARGB(255, 8, 220, 15),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            title: const Text(
              'Qarazdaree',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          floatingActionButton: Builder(
            builder: ((context) => FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 5, 249, 13),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                onPressed: () {
                  showDialog(context: context, builder: (context) => Fourm());
                })),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: pages[index],
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // HOME BUTTON
                  GestureDetector(
                    onTap: () {
                      ref.read(navigationProvider.notifier).state = 0;
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_2_outlined,
                          size: index == 0 ? 32 : 24,
                          color: index == 0 ? Colors.black : Colors.grey,
                        ),
                        if (index == 0)
                          const Text(
                            "Home",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // STATISTICS BUTTON
                  GestureDetector(
                    onTap: () {
                      ref.read(navigationProvider.notifier).state = 1;
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.donut_large_outlined,
                          size: index == 1 ? 32 : 24,
                          color: index == 1 ? Colors.black : Colors.grey,
                        ),
                        if (index == 1)
                          const Text(
                            "Statistics",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
