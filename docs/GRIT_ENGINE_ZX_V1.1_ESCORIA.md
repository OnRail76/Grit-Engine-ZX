# GRIT ENGINE ZX · V1.1 · Perfil 6: horizontal_escoria

Tony C. Ware · ZX Spectrum 48K · 2026

## Procedencia
ESCORIA SIDERAL V1.0, commit 8f73623ec7f775e7d997ce24450aaae8c6d708e3. Gold Master: 93.481 bytes, 28 bloques físicos TAP, SHA-256 250c3210909e3479801fbec8212b2745d588a9035ae2c6b7c4d87c847a8990f2. Reconstruido byte a byte durante esta preparación. Se importa el proyecto fijado; no se modifica su repositorio. Los cinco perfiles V1.0 y sus binarios permanecen intactos.

## Arquitectura
- ORG 0x5F00. Motor residente 33.412 bytes y banco sustituible 3.617 bytes. Código y datos iniciales 37.029 bytes, extremo exclusivo 0xEFA5. Búfer 0xF000–0xFCFF (3.328 bytes); pila 0xFD00–0xFFFF. Estas direcciones corresponden al juego aprobado, no a todas las configuraciones.
- Búfer lineal de 32 bytes por fila, y=40–143. render_begin copia límites anteriores y activa shadow_mode; erase_all restaura regiones antiguas; draw_all compone actores, proyectiles y jefe; publish transfiere unión de bandas sucias de 8 filas a VRAM ZX. No se promete publicación atómica a nivel de raster.
- Sprites 32×32, máscaras, alineaciones precomputadas, filas dispersas y diccionario de hasta 208 entradas. El jefe 48×64 utiliza base y parches de ojo/boca. Selección de vía rápida solo cuando no hay solapamiento.
- Suelo repetible de 192×24, cuatro variantes de alineación, 96 desplazamientos de 2 px. Fondo fijo, HUD independiente.
- Director con máximo cuatro enemigos normales y un origen trasero; ataques ambientales, límites de concurrencia, invulnerabilidad de reaparición de 100 interrupciones. Colisiones y patrones del juego son política del perfil, no ABI común.
- IM1 con FRAMES de ROM; sincronización objetivo 25 Hz. audio_game reserva ~8.000 T-states cuando hay efecto activo incluso si el renderizado rebasa el objetivo; audio_wait usa el margen restante. Prioridad de 1 a 9, sin reinicio por igual/menor prioridad excepto muerte de jefe. El coste real depende de la contención ULA.
- Multicarga por cabeceras CODE verificadas, destino y longitud; conserva puntuación y vidas. Pantalla de carga con espera de pulsación nueva; stub transitorio. Kempston y teclado simultáneos; filtro de direcciones opuestas.

## Uso
```sh
python3 -m pip install -r requirements.txt
python3 grit.py import Escoria-Sideral
python3 grit.py build horizontal_escoria
python3 grit.py test horizontal_escoria
python3 grit.py demo6
```
El último comando crea demo/horizontal_escoria/GRIT_ENGINE_DEMO6_RUN_AND_GUN.tap; sin campaña ni pantalla de carga, solo fase 1 y su jefe, menú técnico propio, X para salir; tras victoria o Game Over, FIRE vuelve al menú. Se genera en una copia temporal; no modifica el original. TAP probado: 35.823 bytes, seis bloques, SHA-256 450e9447ab9e19bd401e828cb4520b0c50f2acfb9e44b31c2caecd6eff44d198. La prueba automática ejecuta título, movimiento, retorno X, reinicio, rutas de victoria/derrota y Kempston. No simula un combate entero nuevo. Posteriormente el autor confirmó que la demo autónoma funciona en Fuse.

## Evidencias y límites
Registros originales de Escoria: test_render_212_results.txt (300 actualizaciones, cinco fases, pico nominal 128.720 T); test_audio212_results.txt (nueve efectos y cuatro actores + meteorito en las cinco fases); test_boss_212_results.txt (cinco muertes, 96 posiciones de suelo y SCR final); test_kempston_results.txt (2.048 combinaciones); test_loading_results.txt (28 bloques). Son resultados del juego, no de la nueva demo. La prueba de la demo autónoma fue confirmada en Fuse por el autor. La integración con el selector común pasó las regresiones y el autor confirmó su funcionamiento en Fuse el 26/11/2026. No se ha certificado hardware físico. No se certifica 25 FPS reales ni ABI universal.

## Estado de V1.1 estable
Selector común de seis perfiles verificado por simulación y aprobado por el autor en Fuse. Esta documentación complementa el manual PDF histórico V1.0. La demo de cinco perfiles V1.0 conserva su TAP y funcionamiento. Código y arte con las licencias y atribuciones originales; no se amplían derechos sobre recursos.

## Integración del selector común

La versión oficial contiene un TAP de 77.802 bytes y seis bloques físicos. El bloque de 40.960 bytes de los perfiles 1–5 y el de 36.731 bytes de la sexta prueba se cargan alternativamente; no se pretende hacerlos coexistir en 48K. Las cinco pruebas anteriores conservan el cambio en RAM. La sexta entra directamente al combate y retorna al menú tras X, derrota o victoria, mediante una recarga de la misma cinta. La entrada indica PLAY CINTA SPACE; al salir indica REBOBINA Y SPACE. Ambos cargadores esperan a que se suelte SPACE antes de acceder a la ROM, para evitar BREAK. El constructor y los mapas están descritos en [demo/technology_demo_v11/LEEME.md](../demo/technology_demo_v11/LEEME.md).
