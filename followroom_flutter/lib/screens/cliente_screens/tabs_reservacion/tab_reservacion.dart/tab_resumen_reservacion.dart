import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';

class TabResumen extends StatefulWidget {
  const TabResumen({super.key});

  @override
  State<TabResumen> createState() => _TabResumenState();
}

class _TabResumenState extends State<TabResumen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(color: AppColores.secundary),
          ),
          SizedBox(height: 10),

          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(color: AppColores.secundary),
          ),
          SizedBox(height: 10),

          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(color: AppColores.secundary),
          ),
          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(color: AppColores.secundary),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(color: AppColores.secundary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
