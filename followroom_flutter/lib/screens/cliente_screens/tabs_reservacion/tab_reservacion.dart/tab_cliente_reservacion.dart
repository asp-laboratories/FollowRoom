import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/input_styles.dart';

class TabClienteReservacion extends StatefulWidget {
  const TabClienteReservacion({super.key});

  @override
  State<TabClienteReservacion> createState() => _TabClienteReservacionState();
}

class _TabClienteReservacionState extends State<TabClienteReservacion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: 
        SingleChildScrollView(
child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre completo"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Apellido paterno"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Apellido Materno"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("RFC"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Nombre fiscal"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Contacto"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Telefono"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Correo electronico"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Direccion"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Colonia"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Calle"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
            Text("Numero"),
            TextField(
              decoration: createAppDecoration(
                labelText: 'Ingresar nombre',
                prefixIcon: Icon(Icons.perm_identity),
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}
