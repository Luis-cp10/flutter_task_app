import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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

  //  CALENDARIO
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // FECHA
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

  // AGREGAR
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
        _selectedIndex = 0;
      });
    }
  }

  // ELIMINAR
  void eliminarTarea(int index) {
    setState(() {
      tareas.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tarea eliminada 🗑️")),
    );
  }

  // CONTADORES
  int get hoyCount => tareas
      .where((t) =>
          t.fecha != null &&
          isSameDay(t.fecha, DateTime.now()) &&
          !t.completada)
      .length;

  int get programadoCount =>
      tareas.where((t) => t.fecha != null && !t.completada).length;

  int get todoCount => tareas.where((t) => !t.completada).length;

  int get indicadorCount =>
      tareas.where((t) => t.indicador && !t.completada).length;

  // FILTRO
  List<Task> get tareasFiltradas {
    DateTime now = DateTime.now();

    return tareas.where((t) {
      if (t.completada) return false;

      switch (filtro) {
        case "hoy":
          return t.fecha != null && isSameDay(t.fecha, now);
        case "programadas":
          return t.fecha != null;
        case "indicador":
          return t.indicador;
        default:
          return true;
      }
    }).toList();
  }

  //  CALENDARIO UI
  Widget _buildCalendar() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2100),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) =>
              isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return tareas.where((t) {
              return t.fecha != null &&
                  isSameDay(t.fecha, day);
            }).toList();
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: _selectedDay == null
              ? Center(child: Text("Selecciona un día"))
              : _buildTasksForSelectedDay(),
        )
      ],
    );
  }

  //  TAREAS DEL DÍA
  Widget _buildTasksForSelectedDay() {
    final tareasDelDia = tareas.where((t) {
      return t.fecha != null &&
          isSameDay(t.fecha, _selectedDay);
    }).toList();

    if (tareasDelDia.isEmpty) {
      return Center(child: Text("No hay tareas para este día"));
    }

    return ListView.builder(
      itemCount: tareasDelDia.length,
      itemBuilder: (context, index) {
        final tarea = tareasDelDia[index];

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              tarea.titulo,
              style: TextStyle(
                decoration: tarea.completada
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(tarea.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.flag,
                    color: tarea.indicador ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      tarea.indicador = !tarea.indicador;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: tarea.completada ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      tarea.completada = !tarea.completada;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    eliminarTarea(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // DASHBOARD
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
              _buildSummaryCard(Icons.calendar_today, "Hoy",
                  hoyCount, Colors.blueAccent, "hoy"),
              _buildSummaryCard(Icons.event, "Programado",
                  programadoCount, Colors.redAccent, "programadas"),
              _buildSummaryCard(Icons.home, "Todas",
                  todoCount, Colors.grey, "todas"),
              _buildSummaryCard(Icons.flag, "Indicador",
                  indicadorCount, Colors.orange, "indicador"),
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
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          tarea.titulo,
                          style: TextStyle(
                            decoration: tarea.completada
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(tarea.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🚩 INDICADOR
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

                            // ✅ COMPLETAR
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: tarea.completada
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  tarea.completada = !tarea.completada;
                                });
                              },
                            ),

                            // 🗑️ ELIMINAR
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                eliminarTarea(tareas.indexOf(tarea));
                              },
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
          color: Colors.white,
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

  // FORM
  Widget _buildAddForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nueva Tarea",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(
                    labelText: "Título de la tarea",
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fechaSeleccionada == null
                            ? "Selecciona una fecha"
                            : "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: seleccionarFecha,
                      child: Text("Elegir"),
                    )
                  ],
                ),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: agregarTarea,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Guardar Tarea",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildCalendar();
      case 2:
        return _buildAddForm();
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