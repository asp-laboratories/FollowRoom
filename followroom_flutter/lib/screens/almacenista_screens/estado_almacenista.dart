import 'package:flutter/material.dart';
import 'package:followroom_flutter/screens/almacenista_screens/subnavbar_almacenista.dart';

class AlmacenistaEstadoScreen extends StatefulWidget {
  const AlmacenistaEstadoScreen({super.key});

  @override
  State<AlmacenistaEstadoScreen> createState() => _AlmacenistaEstadoScreenState();
}

class _AlmacenistaEstadoScreenState extends State<AlmacenistaEstadoScreen> {
  int _actualIndice = 0;
  bool _buscar = true;
  bool _cagando = true;

  List<dynamic> _cosas = [];

  @override
  void initState() {
    super.initState();
    _datosBaseDatos();
  }

  Future<void> _datosBaseDatos() async {

    // logica pa jalar la info de django
    final List<dynamic> datosObtenidos;

    _actualIndice == 0
      ? datosObtenidos = [{'cosa': 'Sila fea', 'cantidadDisponible': 20}, {'cosa': 'Sila bonita', 'cantidadDisponible': 10}]
      : datosObtenidos = [{'cosa': 'laptop vieja', 'cantidadDisponible': 10}];

    // pa simular la epsera
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _cosas = datosObtenidos;
      _cagando = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    if (_actualIndice == 0) {
      _buscar = true;
    } else {
      _buscar = false;
    }

    return Column(

      children: [
        Textos(
          
          texts: ['Mobiliarios', 'Equipamientos',],
          
          seleccionActual: _actualIndice,
          
          alSeleccionar: (int nuevoIndice) {
            setState(() {
              _actualIndice = nuevoIndice;
            });
          }, 
        ),
        
        Expanded(

          child: _cagando
            ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
            : ListView.builder(
            
              itemCount: _cosas.length,

              itemBuilder: (context, index) {
                final itemActual = _cosas[index];

                return Padding(
                  padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                      
                        context: context, 
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,

                        builder: (BuildContext context) {
                        
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),

                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(10), 
                                child: TarjetaMobiliarioElegante(idMobiliario: 1, equipamientoMobiliario: _buscar),
                              ),

                            ),

                          );

                        },

                      );


                    },

                    child: Container(
                    
                      height: 100,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.black,
                          style: BorderStyle.solid,
                          width: 3,

                        ),
                      ),

                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              itemActual['cosa'],

                            ),

                            SizedBox(height: 10,),

                            Row(
                              children: [
                                Text(
                                  "Disponibles: ${itemActual['cantidadDisponible'].toString()}",
                                ),
                                Spacer(),
                                Text(
                                  "Inspeccionar >"
                                )
                              ],
                            ),

                          ],

                        ),

                      )

                    ),

                  ),

                );

              },


            ),
        ),

      ],

    );
  
  }

}

class TarjetaMobiliarioElegante extends StatelessWidget {
  final int idMobiliario;
  final bool equipamientoMobiliario; // Este nos dice si es equipamiento o mobiliario

  TarjetaMobiliarioElegante({super.key, required this.idMobiliario, required this.equipamientoMobiliario});

  // Logica para obtener datos del mobilairios
  final String nombre = "silla fea";
  final String urlImage = "https://thumbs.dreamstime.com/z/silla-fea-maciza-aislada-en-el-fondo-blanco-101306793.jpg";
  final List<Map> estaos = [
  ];

  @override
  Widget build(BuildContext context) {

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),

                  child: Image.network(
                    urlImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,

                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 60, height: 60,
                        child: Center(child: CircularProgressIndicator(),),
                      );
                    },

                  ),

                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${equipamientoMobiliario ? 'Mobiliario' : 'Equipamiento'}: $nombre",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            Text("Estados:", 
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 8),

            // Cambair datos para q coincidan con la logica obtenida de la base ded atos

            ListView.builder(
            
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            
              itemCount: estaos.length,
              
              itemBuilder: (context, index) {
            
                final itemActual = estaos[index];
              
                return _buildEstadoRow(context, itemActual['nombreEstado'], itemActual['cantidad'].toString(), 
                index == 0 
                  ? Colors.green
                  : index == (estaos.length - 1)
                    ? Colors.red
                    : Colors.orange);
            
              }
            
            ),

            const Divider(),
            
            Text("Registrar Movimiento:", 
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildSmallInput(context, "De (estado)", Icons.output_rounded),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSmallInput(context, "A (estado)", Icons.input_rounded),
                ),
              ],
            ),
            
            const SizedBox(height: 15),

            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: _buildSmallInput(context, "Total", Icons.numbers, isNumber: true),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Envio de datos para cambio de estado

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text(
                      "Cambiar Estado",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las filas de estado (con el punto de color)
  Widget _buildEstadoRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text("$label: ", style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // Widget para los campos de texto modernos
  Widget _buildSmallInput(BuildContext context, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(10),
           borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        
        filled: true,
        fillColor: Colors.grey.shade50, 
      ),
    );
  }
}