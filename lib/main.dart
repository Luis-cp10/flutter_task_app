import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task App',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

// MODELO
class Task {
  String titulo;
  String email;
  bool completada;
  DateTime? fecha;
  bool indicador;

  Task(this.titulo, this.email,
      {this.completada = false, this.fecha, this.indicador = false});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final tituloController = TextEditingController();
  final emailController = TextEditingController();

  List<Task> tareas = [];
  DateTime? fechaSeleccionada;

  int _selectedIndex = 0;
  String filtro = "todas";

  //  FECHA
  void seleccionarFecha() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  //  AGREGAR
  void agregarTarea() async {
    if (tituloController.text.isEmpty || emailController.text.isEmpty) return;

    bool ok = await ApiService.crearTarea(
      tituloController.text,
      emailController.text,
      fechaSeleccionada,
    );

    if (ok) {
      setState(() {
        tareas.add(Task(
          tituloController.text,
          emailController.text,
          fecha: fechaSeleccionada,
        ));

        tituloController.clear();
        emailController.clear();
        fechaSeleccionada = null;
        _selectedIndex = 0; // vuelve a home
      });
    }
  }

  //  ELIMINAR
  void eliminarTarea(int index) {
    setState(() {
      tareas.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tarea eliminada 🗑️")),
    );
  }

  //  CONTADORES
  int get hoyCount => tareas
      .where((t) =>
          t.fecha != null &&
          t.fecha!.day == DateTime.now().day &&
          t.fecha!.month == DateTime.now().month &&
          t.fecha!.year == DateTime.now().year &&
          !t.completada)
      .length;

  int get programadoCount =>
      tareas.where((t) => t.fecha != null && !t.completada).length;

  int get todoCount => tareas.where((t) => !t.completada).length;

  int get indicadorCount =>
      tareas.where((t) => t.indicador && !t.completada).length;

  // 🔍 FILTRO
  List<Task> get tareasFiltradas {
    DateTime now = DateTime.now();

    return tareas.where((t) {
      if (t.completada) return false;

      switch (filtro) {
        case "hoy":
          return t.fecha != null &&
              t.fecha!.day == now.day &&
              t.fecha!.month == now.month &&
              t.fecha!.year == now.year;
        case "programadas":
          return t.fecha != null;
        case "indicador":
          return t.indicador;
        default:
          return true;
      }
    }).toList();
  }

  //  DASHBOARD
  Widget _buildDashboard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildSummaryCard(Icons.calendar_today, "Hoy", hoyCount,
                  Colors.blueAccent, "hoy"),
              _buildSummaryCard(Icons.event, "Programado", programadoCount,
                  Colors.redAccent, "programadas"),
              _buildSummaryCard(Icons.home, "Todas", todoCount,
                  Colors.grey, "todas"),
              _buildSummaryCard(Icons.flag, "Indicador", indicadorCount,
                  Colors.orange, "indicador"),
            ],
          ),
        ),
        Divider(),

        Expanded(
          child: tareasFiltradas.isEmpty
              ? Center(child: Text("No hay tareas"))
              : ListView.builder(
                  itemCount: tareasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarea = tareasFiltradas[index];

                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            setState(() {
                              tarea.completada = true;
                            });
                          },
                          child: Icon(
                            tarea.completada
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: tarea.completada
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                        title: Text(tarea.titulo,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tarea.email),
                            SizedBox(height: 5),
                            Wrap(
                              spacing: 6,
                              children: [
                                if (tarea.fecha != null)
                                  Chip(
                                    label: Text(
                                        "📅 ${tarea.fecha!.day}/${tarea.fecha!.month}/${tarea.fecha!.year}"),
                                  ),
                                if (tarea.indicador)
                                  Chip(label: Text("Indicador")),
                              ],
                            )
                          ],
                        ),

                        // 🚩 + 🗑
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.flag,
                                color: tarea.indicador
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  tarea.indicador = !tarea.indicador;
                                });
                              },
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  eliminarTarea(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      IconData icon, String label, int count, Color color, String tipo) {
    return GestureDetector(
      onTap: () {
        setState(() {
          filtro = tipo;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 10),
            Text("$label ($count)"),
          ],
        ),
      ),
    );
  }

  //  FORMULARIO DIRECTO
  Widget _buildAddForm() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("Nueva Tarea",
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Text(
                    fechaSeleccionada == null
                        ? "Sin fecha"
                        : "📅 ${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}",
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: seleccionarFecha,
                )
              ],
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                agregarTarea();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Tarea agregada 🚀")),
                );
              },
              child: Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return Center(child: Text("Calendario (pendiente)"));
      case 2:
        return _buildAddForm(); 
      case 3:
        return Center(child: Text("Configuración"));
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager"),
        centerTitle: true,
      ),
      body: _buildContent(),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Calendario"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box), label: "Añadir"),
        ],
      ),
    );
  }
}