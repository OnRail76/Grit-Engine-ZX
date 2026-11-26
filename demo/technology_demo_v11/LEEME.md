# GRIT ENGINE ZX — Technology Demo V1.1-dev
Tony C. Ware · ZX Spectrum 48K · 2026

## Uso en Fuse
Abre GRIT_ENGINE_TECH_DEMO_V1.1.tap en modo 48K, con carga rápida de cinta si está disponible. LOAD "".
El menú común contiene 1 Circo, 2 Space Shooter, 3 Arena, 4 Ground Combat, 5 Vertical Shmup y 6 Run & Gun (Escoria Sideral, fase 1).
Selecciona 1–6 o Q/A + SPACE/FIRE. X vuelve al menú. En 5 y 6, perder todas las vidas o derrotar al jefe también conduce al selector (en 6, tras la pantalla de fin y FIRE).

Las primeras cinco pruebas cambian en RAM, como V1.0. Al entrar en la sexta, el motor muestra PLAY CINTA SPACE. Pulsa y suelta SPACE; continúa desde la posición actual, y activa la reproducción si el emulador lo requiere. Al volver, el motor muestra REBOBINA Y SPACE: rebobina la misma cinta y pulsa y suelta SPACE. No reinicies la máquina. El cargador busca el bloque correspondiente. También se puede situar la cinta directamente en la cabecera CODE buscada.

## Construcción reproducible
Desde la raíz del motor:

    python3 -m pip install -r requirements.txt
    python3 grit.py import Escoria-Sideral
    python3 grit.py demo6
    python3 demo/technology_demo_v11/build.py
    python3 demo/technology_demo_v11/test_switch.py

TAP conjunto: 77.802 bytes, seis bloques físicos, SHA-256:
82036bb66376e3465ed91e7ab0d973cd429a39d0c5a528c5b0a153ef72dc7032

## Memoria y alcance
Dos imágenes alternativas: 40.960 bytes en 0x6000–0xFFFF y 36.731 bytes en 0x5B00–0xEA7A (prefijo de 1.024 bytes más el núcleo de la demo 6, 35.707 bytes).
Los stubs de 224 bytes se alojan en 0xFF20 y 0x5B00 respectivamente y se relocalizan en pantalla a 0x5000 antes de efectuar la transferencia. La pila de carga es 0x57F0; cabecera en 0x5780; vectores IM2 de carga en 0x5600; ISR en 0x5555. El sexto perfil usa IM2 privado, tabla 0x5D00 y un contador compatible con FRAMES en 0x5C78. La fase comienza directamente; los tres caminos de salida recargan el bloque de menú. Los motores no coexisten en RAM.

El constructor usa copias temporales y verifica las huellas de ambas demos originales. El binario V1.0 permanece idéntico. Regresiones: cinco perfiles originales, 500 actualizaciones nominales, navegación a 6, transferencia de carga, primer movimiento de la sexta, vuelta desde X/derrota/victoria y nueva entrada al perfil arena. ROM LD_BYTES e interrupciones simuladas; falta verificar la cinta real en Fuse, especialmente el rebobinado. No se afirma que la V1.1 integrada esté aprobada aún.

## FIX 1
El cargador espera que SPACE se suelte antes de llamar a LD-BYTES ($0556); mantener SPACE podía activar BREAK en SA/LD-RET ($053F). Regresión: 120 instrucciones con SPACE mantenido, sin acceso a cinta, y entrada desde posición 4 o 0. No se modifican los bytes de los motores.
