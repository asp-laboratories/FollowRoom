import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class TabSalon extends StatefulWidget {
  const TabSalon({super.key});

  @override
  State<TabSalon> createState() => _TabSalonState();
}

class _TabSalonState extends State<TabSalon> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: AppColores.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Salon"),
                Text("Salon"),
                Text("Salon"),

                Row(
                  children: [
                    Text("data"),
                    Text("data"),
                  ],
                )
              ],
            )
          ),
        ),
      ],
    );
  }
}
