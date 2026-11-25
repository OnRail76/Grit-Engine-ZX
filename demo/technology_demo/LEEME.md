# GRIT ENGINE — TECHNOLOGY DEMO V1.0
Tony C. Ware · ZX Spectrum 48K

Cargar el TAP una vez. Seleccionar 1–5, o Q/A y SPACE/FIRE. X vuelve al menú. La quinta prueba contiene exclusivamente el Mediterráneo: acceso directo, sin título ni pantalla de carga de Neptuno, retorno al menú con X, al perder todas las vidas o al vencer al jefe. No requiere rebobinado ni cargas adicionales.

## Construcción y pruebas
`python3 build.py` genera los binarios, listados ASM, símbolos y TAP a partir de las entradas incluidas. Los emisores Python son la fuente canónica del ensamblado de esta edición. `python3 test_demo.py` ejecuta las regresiones con Pillow. El registro PRUEBAS_V1.0.log documenta el simulador parcial Z80; no certifica temporización exacta de hardware. El nombre interno de las rutinas y los registros históricos puede conservar nomenclaturas anteriores.

El TAP V1.0 es el binario de la última demostración entregada (anteriormente denominada RC2), sin modificación de bytes. SHA-256: `1e8ba440885f76da162da0518e5120b1b16f13d4600b289c1494d19305cdfd31`.
