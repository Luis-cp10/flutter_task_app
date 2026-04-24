# flutter_task_app
---
MANUAL TÉCNICO – TASK MANAGER APP

1.  Descripción Esta aplicación fue desarrollada en Flutter y permite
    gestionar tareas de manera sencilla. El usuario puede crear tareas,
    asignarles una fecha, marcarlas como completadas y organizarlas
    mediante filtros.
---
2.  Tecnologías usadas

-   Flutter
-   Dart
-   N8n
---
3.  Estructura del proyecto

-   main.dart → archivo principal
-   api_service.dart → conexión con el backend
---
4.  Modelo de datos La aplicación maneja una clase llamada Task con los
    siguientes datos:

-   titulo: nombre de la tarea
-   email: usuario asociado
-   completada: estado (true o false)
-   fecha: fecha de la tarea (opcional)
-   indicador: marca de prioridad
---
5.  Funcionalidades

-   Crear tareas
-   Asignar fecha
-   Ver tareas en lista
-   Marcar como completadas
-   Eliminar tareas
-   Marcar tareas importantes (indicador)
---
6.  Filtros disponibles

-   Hoy → tareas del día actual
-   Programadas → tareas con fecha
-   Todas → todas las tareas
-   Indicador → tareas importantes
---
7.  Pantallas

-   Home → muestra tareas y resumen
-   Añadir → formulario para crear tareas
-   Calendario → pendiente
---
8.  Funcionamiento

-  El usuario ingresa título y email

- Puede seleccionar una fecha

- Guarda la tarea

- La tarea se envía a la API

- Se muestra en la lista
---
14. Estado de la app

-   Funciona correctamente para crear y gestionar tareas
-   El calendario aún no está implementado
-   Depende de la API para guardar datos
---
10. Mejoras futuras

-   Notificaciones
-   Editar tareas
-   Guardado local
---
11. Autor Luis Castillo

