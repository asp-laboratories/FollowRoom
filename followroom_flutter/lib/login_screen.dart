import 'package:flutter/material.dart';
import 'package:followroom_flutter/screens/cliente_screens/reservacion_screen.dart';
import 'package:followroom_flutter/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  String mensajeError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 24,),
        TextField(
          controller: email,
          decoration: InputDecoration(
            labelText: 'Ingresa un correo electronico',
            border: OutlineInputBorder(),
            prefix: Icon(Icons.person)
          ),
        ),
        SizedBox(height: 24,),
        TextField(
          controller: password,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(),
            prefix: Icon(Icons.password)
          ),
        ),
        SizedBox(height: 24,),
        ElevatedButton(onPressed: (){
          if(email.text == 'example' && password.text =='123'){
            Navigator.push(context,
            MaterialPageRoute(builder: (context)=>FollowRoom()));
          } else {
            setState(() {
              mensajeError = "Campos incorrectos";
            });
          }
        },
         child: Text("Iniciar sesión")),
         Text(mensajeError),
         ElevatedButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Registro()));
         }, child: Text("Registrate"))
      ],
      )
    );
  }
}