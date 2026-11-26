# GRIT ENGINE ZX — Technology Demo V1.1-dev
Tony C. Ware · ZX Spectrum 48K · 2026

## Uso en Fuse
Abre GRIT_ENGINE_TECH_DEMO_V1.1.tap en modo 48K, con carga rápida de cinta si está disponible. LOAD "".
El menú común contiene 1 Circo, 2 Space Shooter, 3 Arena, 4 Ground Combat, 5 Vertical Shmup y 6 Run & Gun (Escoria Sideral, fase 1).
Selecciona 1–6 o Q/A + SPACE/FIRE. X vuelve al menú. En 5 y 6, perder todas las vidas o derrotar al jefe también conduce al selector (en 6, tras la pantalla de fin y FIRE).

Las primeras cinco pruebas cambian en RAM, como V1.0. Al pasar a la sexta o volver desde ella, el motor muestra REBOBINA Y SPACE. Rebobina la misma cinta, pulsa SPACE y activa su reproducción si el emulador lo requiere. No reinicies la máquina. El cargador busca el bloque correspondiente. También se puede situar la cinta directamente en la cabecera CODE buscada.

## Construcción reproducible
Desde la raíz del motor:

    python3 -m pip install -r requirements.txt
    python3 grit.py import Escoria-Sideral
    python3 grit.py demo6
    python3 demo/technology_demo_v11/build.py
    python3 demo/technology_demo_v11/test_switch.py

TAP conjunto: 77.802 bytes, seis bloques físicos, SHA-256:
81c386b7f9d5bcc854f3b778a809967518318f74c93b6dc84825a08118add53b

## Memoria y alcance
Dos imágenes alternativas: 40.960 bytes en 0x6000–0xFFFF y 36.731 bytes en 0x5B00–0xEA7A (prefijo de 1.024 bytes más el núcleo de la demo 6, 35.707 bytes).
Los stubs de 218 bytes se alojan en 0xFF20 y 0x5B00 respectivamente y se relocalizan en pantalla a 0x5000 antes de efectuar la transferencia. La pila de carga es 0x57F0; cabecera en 0x5780; vectores IM2 de carga en 0x5600; ISR en 0x5555. El sexto perfil usa IM2 privado, tabla 0x5D00 y un contador compatible con FRAMES en 0x5C78. La fase comienza directamente; los tres caminos de salida recargan el bloque de menú. Los motores no coexisten en RAM.

El constructor usa copias temporales y verifica las huellas de ambas demos originales. El binario V1.0 permanece idéntico. Regresiones: cinco perfiles originales, 500 actualizaciones nominales, navegación a 6, transferencia de carga, primer movimiento de la sexta, vuelta desde X/derrota/victoria y nueva entrada al perfil arena. ROM LD_BYTES e interrupciones simuladas; falta verificar la cinta real en Fuse, especialmente el rebobinado. No se afirma que la V1.1 integrada esté aprobada aún.
