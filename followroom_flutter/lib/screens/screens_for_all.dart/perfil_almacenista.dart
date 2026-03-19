import 'package:flutter/material.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            // children: [
            //   CircleAvatar(
            //     radius: 50,
            //     backgroundImage: NetworkImage(
            //         "https://www.pngall.com/wp-content/uploads/5/Profile-PNG-High-Quality-Image.png"),
            //   ),
            //   Positioned(
            //     bottom: 0,
            //     right: 0,
            //     child: Container(
            //       padding: EdgeInsets.all(4),
            //       decoration: BoxDecoration(
            //         color: Colors.blue,
            //         shape: BoxShape.circle,
            //       ),
            //       child: Icon(
            //         Icons.edit,
            //         size: 16,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ],

          ),
          Text("Nombre de usuario"),
          TextField(decoration: InputDecoration(hintText: "Nombre de usuario")),

          Text("Correo"),
          TextField(decoration: InputDecoration(hintText: "Correo")),

          Text("Contraseña"),
          ElevatedButton(onPressed: (){}, child: Text("Enviar correo")),

          ElevatedButton(onPressed: (){}, child: Text("Actualizar perfil"))
        ],
      ),
    );
  }
}
