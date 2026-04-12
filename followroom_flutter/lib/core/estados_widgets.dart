import 'package:flutter/material.dart';
import 'package:followroom_flutter/core/colores.dart';
import 'package:followroom_flutter/core/boton_styles.dart';

class ErrorWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onRetry;
  final IconData icono;

  const ErrorWidget({
    super.key,
    this.mensaje = 'Error de conexión',
    this.onRetry,
    this.icono = Icons.wifi_off,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 64, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            Text(
              'Algo salió mal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColores.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColores.foreground.withValues(alpha: 0.7),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: BotonStyles.botonesAccion,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final VoidCallback? onRetry;
  final bool esErrorConexion;

  const ErrorDisplay({
    super.key,
    this.titulo = 'Algo salió mal',
    this.mensaje = 'Hubo un problema al cargar los datos',
    this.onRetry,
    this.esErrorConexion = false,
  });

  factory ErrorDisplay.conexion({String? mensaje, VoidCallback? onRetry}) {
    return ErrorDisplay(
      titulo: 'Sin conexión',
      mensaje:
          mensaje ??
          'No se pudo conectar al servidor. Verifica tu conexión a internet.',
      onRetry: onRetry,
      esErrorConexion: true,
    );
  }

  factory ErrorDisplay.carga({
    required String queSeCargaba,
    VoidCallback? onRetry,
  }) {
    return ErrorDisplay(
      titulo: 'Error al cargar',
      mensaje: 'No se pudo cargar $queSeCargaba. Por favor intenta de nuevo.',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: esErrorConexion
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  esErrorConexion ? Icons.wifi_off : Icons.error_outline,
                  size: 64,
                  color: esErrorConexion ? Colors.orange[400] : Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColores.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColores.foreground.withValues(alpha: 0.7),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 160,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColores.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String mensaje;

  const LoadingWidget({super.key, this.mensaje = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColores.primary),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 14,
              color: AppColores.foreground.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String titulo;
  final String? mensaje;
  final IconData icono;
  final Widget? accion;

  const EmptyStateWidget({
    super.key,
    required this.titulo,
    this.mensaje,
    this.icono = Icons.inbox,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColores.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  size: 64,
                  color: AppColores.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColores.foreground,
                ),
              ),
              if (mensaje != null) ...[
                const SizedBox(height: 8),
                Text(
                  mensaje!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColores.foreground.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (accion != null) ...[const SizedBox(height: 24), accion!],
            ],
          ),
        ),
      ),
    );
  }
}
